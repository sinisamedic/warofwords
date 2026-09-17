-- Preserve v1 attempts and RPCs; separate rankings for the new refill rules.
begin;
alter table public.daily_attempts drop constraint daily_attempts_version_check;
alter table public.daily_attempts add constraint daily_attempts_version_check check (version in ('daily-v1','daily-v2'));
create function public.daily_start_versioned(p_user uuid, p_language text, p_adjacent boolean, p_nickname text, p_seed integer, p_version text)
returns jsonb language plpgsql security definer set search_path=public as $$
declare result public.daily_attempts;
  challenge_day date := (clock_timestamp() at time zone 'UTC')::date;
  challenge_seed integer;
begin
  if p_version not in ('daily-v1','daily-v2') then raise exception 'Unsupported rules'; end if;
  insert into public.daily_challenges(day,language,adjacent,seed,version)
  values(challenge_day,p_language,p_adjacent,p_seed,p_version)
  on conflict (day,language,adjacent,version) do nothing;
  select seed into challenge_seed from public.daily_challenges
  where day=challenge_day and language=p_language and adjacent=p_adjacent and version=p_version;
  insert into public.daily_attempts(user_id,day,language,adjacent,nickname,seed,version)
  values(p_user,challenge_day,p_language,p_adjacent,p_nickname,challenge_seed,p_version)
  on conflict (user_id,day,language,adjacent,version) do nothing;
  select * into result from public.daily_attempts
  where user_id=p_user and day=challenge_day
    and language=p_language and adjacent=p_adjacent and version=p_version;
  return to_jsonb(result);
end $$;

create function public.daily_leaderboard_versioned(p_user uuid, p_language text, p_adjacent boolean, p_version text)
returns jsonb language sql stable security definer set search_path=public as $$
  with ranked as (
    select nickname, score, word_count, user_id=p_user as own,
      rank() over(order by score desc) as position,
      row_number() over(order by score desc, finished_at, id) as row_no
    from public.daily_attempts
    where day=(now() at time zone 'UTC')::date and language=p_language
      and adjacent=p_adjacent and version=p_version and finished_at is not null
  ), mine as (select row_no from ranked where own)
  select jsonb_build_object(
    'day',(now() at time zone 'UTC')::date,
    'total',(select count(*) from ranked),
    'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no)
      from ranked r where row_no<=20 or abs(row_no-(select row_no from mine))<=2),'[]'::jsonb)
  );
$$;
revoke all on function public.daily_start_versioned(uuid,text,boolean,text,integer,text) from public, anon, authenticated;
revoke all on function public.daily_leaderboard_versioned(uuid,text,boolean,text) from public, anon, authenticated;
grant execute on function public.daily_start_versioned(uuid,text,boolean,text,integer,text) to service_role;
grant execute on function public.daily_leaderboard_versioned(uuid,text,boolean,text) to service_role;


commit;
