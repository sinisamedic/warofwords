-- Each completed run is deduplicated by its client-generated UUID.
create table public.endless_runs (
 user_id uuid not null references auth.users(id) on delete cascade,
 run_id uuid not null, language text not null check(language in ('en','sr')),
 adjacent boolean not null, nickname text not null check(char_length(nickname) between 3 and 20),
 score integer not null check(score between 0 and 100000000),
 wave integer not null check(wave between 1 and 10000),
 words integer not null check(words between 0 and 100000),
 seconds integer not null check(seconds between 1 and 604800),
 created_at timestamptz not null default now(), primary key(user_id,run_id)
);
alter table public.endless_runs enable row level security;
revoke all on public.endless_runs from public,anon,authenticated;
create function public.endless_finish(p_run uuid,p_language text,p_adjacent boolean,p_nickname text,p_score integer,p_wave integer,p_words integer,p_seconds integer)
returns jsonb language plpgsql security definer set search_path=public as $$
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_nickname is null or char_length(trim(p_nickname)) not between 3 and 20 or p_nickname !~ '^[[:alnum:] _-]+$' then raise exception 'Invalid nickname'; end if;
 insert into endless_runs(user_id,run_id,language,adjacent,nickname,score,wave,words,seconds)
 values(auth.uid(),p_run,p_language,p_adjacent,trim(p_nickname),p_score,p_wave,p_words,p_seconds)
 on conflict(user_id,run_id) do nothing;
 if found and p_score>0 and p_words>0 then
 perform endless_submit(p_language,p_adjacent,p_nickname,p_score,p_wave,p_words,p_seconds);
 end if;
 update endless_scores set nickname=trim(p_nickname) where user_id=auth.uid();
 return jsonb_build_object('saved',true);
end $$;
create function public.endless_name(p_nickname text) returns jsonb language plpgsql security definer set search_path=public as $$
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_nickname is null or char_length(trim(p_nickname)) not between 3 and 20 or p_nickname !~ '^[[:alnum:] _-]+$' then raise exception 'Invalid nickname'; end if;
 update endless_scores set nickname=trim(p_nickname) where user_id=auth.uid();
 return jsonb_build_object('saved',true);
end $$;
revoke all on function public.endless_finish(uuid,text,boolean,text,integer,integer,integer,integer) from public,anon;
revoke all on function public.endless_name(text) from public,anon;
grant execute on function public.endless_finish(uuid,text,boolean,text,integer,integer,integer,integer) to authenticated;
grant execute on function public.endless_name(text) to authenticated;
