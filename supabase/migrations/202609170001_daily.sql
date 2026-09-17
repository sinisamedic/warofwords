-- Private tables. The app can only use the authenticated Edge Function.
create table public.daily_challenges (
  day date not null,
  language text not null check (language in ('en','sr')),
  adjacent boolean not null,
  version text not null default 'daily-v1',
  seed integer not null check (seed between 1 and 2147483646),
  primary key(day,language,adjacent,version)
);
alter table public.daily_challenges enable row level security;
revoke all on public.daily_challenges from anon, authenticated;
grant all on public.daily_challenges to service_role;

create table public.daily_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  day date not null,
  language text not null check (language in ('en','sr')),
  adjacent boolean not null,
  version text not null default 'daily-v1' check (version='daily-v1'),
  nickname text not null check (char_length(nickname) between 3 and 20),
  seed integer not null check (seed between 1 and 2147483646),
  started_at timestamptz not null default clock_timestamp(),
  finished_at timestamptz,
  score integer check (score between 0 and 96000),
  word_count integer check (word_count between 0 and 240),
  unique (user_id, day, language, adjacent, version)
);
create index daily_ranking on public.daily_attempts (day, language, adjacent, version, score desc)
where finished_at is not null;
alter table public.daily_attempts enable row level security;
revoke all on public.daily_attempts from anon, authenticated;
grant all on public.daily_attempts to service_role;

create function public.daily_start(p_user uuid, p_language text, p_adjacent boolean, p_nickname text, p_seed integer)
returns jsonb language plpgsql security definer set search_path=public as $$
declare result public.daily_attempts;
  challenge_day date := (clock_timestamp() at time zone 'UTC')::date;
  challenge_seed integer;
begin
  insert into public.daily_challenges(day,language,adjacent,seed)
  values(challenge_day,p_language,p_adjacent,p_seed)
  on conflict (day,language,adjacent,version) do nothing;
  select seed into challenge_seed from public.daily_challenges
  where day=challenge_day and language=p_language and adjacent=p_adjacent and version='daily-v1';
  insert into public.daily_attempts(user_id,day,language,adjacent,nickname,seed)
  values(p_user,challenge_day,p_language,p_adjacent,p_nickname,challenge_seed)
  on conflict (user_id,day,language,adjacent,version) do nothing;
  select * into result from public.daily_attempts
  where user_id=p_user and day=challenge_day
    and language=p_language and adjacent=p_adjacent and version='daily-v1';
  return to_jsonb(result);
end $$;

create function public.daily_leaderboard(p_user uuid, p_language text, p_adjacent boolean)
returns jsonb language sql stable security definer set search_path=public as $$
  with ranked as (
    select nickname, score, word_count, user_id=p_user as own,
      rank() over(order by score desc) as position,
      row_number() over(order by score desc, finished_at, id) as row_no
    from public.daily_attempts
    where day=(now() at time zone 'UTC')::date and language=p_language
      and adjacent=p_adjacent and version='daily-v1' and finished_at is not null
  ), mine as (select row_no from ranked where own)
  select jsonb_build_object(
    'day',(now() at time zone 'UTC')::date,
    'total',(select count(*) from ranked),
    'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no)
      from ranked r where row_no<=20 or abs(row_no-(select row_no from mine))<=2),'[]'::jsonb)
  );
$$;
revoke all on function public.daily_start(uuid,text,boolean,text,integer) from public, anon, authenticated;
revoke all on function public.daily_leaderboard(uuid,text,boolean) from public, anon, authenticated;
grant execute on function public.daily_start(uuid,text,boolean,text,integer) to service_role;
grant execute on function public.daily_leaderboard(uuid,text,boolean) to service_role;

insert into storage.buckets(id,name,public,file_size_limit)
values ('daily-dictionaries','daily-dictionaries',false,10000000)
on conflict (id) do nothing;
-- No public storage policies: dictionary access uses the server-only service key.
