-- Beta leaderboard: authenticated identity, client-reported combat score.
create table public.endless_scores (
 user_id uuid not null references auth.users(id) on delete cascade,
 language text not null check(language in ('en','sr')),
 adjacent boolean not null,
 nickname text not null check(char_length(nickname) between 3 and 20),
 score integer not null check(score between 1 and 100000000),
 wave integer not null check(wave between 1 and 10000),
 words integer not null check(words between 1 and 100000),
 seconds integer not null check(seconds between 1 and 604800),
 updated_at timestamptz not null default now(),
 primary key(user_id,language,adjacent)
);
alter table public.endless_scores enable row level security;
revoke all on public.endless_scores from public,anon,authenticated;
create function public.endless_submit(p_language text,p_adjacent boolean,p_nickname text,p_score integer,p_wave integer,p_words integer,p_seconds integer)
returns jsonb language plpgsql security definer set search_path=public as $$
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_language is null or p_adjacent is null or p_nickname is null or p_score is null or p_wave is null or p_words is null or p_seconds is null then raise exception 'Invalid result'; end if;
 if char_length(trim(p_nickname)) not between 3 and 20 or p_nickname !~ '^[[:alnum:] _-]+$' then raise exception 'Invalid nickname'; end if;
 insert into endless_scores(user_id,language,adjacent,nickname,score,wave,words,seconds)
 values(auth.uid(),p_language,p_adjacent,trim(p_nickname),p_score,p_wave,p_words,p_seconds)
 on conflict(user_id,language,adjacent) do update set nickname=excluded.nickname,score=excluded.score,wave=excluded.wave,words=excluded.words,seconds=excluded.seconds,updated_at=now()
 where excluded.score>endless_scores.score;
 return jsonb_build_object('saved',true);
end $$;
create function public.endless_leaderboard(p_language text,p_adjacent boolean)
returns jsonb language plpgsql stable security definer set search_path=public as $$
declare result jsonb;
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_language not in ('en','sr') or p_language is null or p_adjacent is null then raise exception 'Invalid category'; end if;
 with ranked as (
 select nickname,score,wave,words, user_id=auth.uid() as own,
 rank() over(order by score desc) as position,
 row_number() over(order by score desc,updated_at,user_id) as row_no
 from endless_scores where language=p_language and adjacent=p_adjacent
 ), mine as(select row_no from ranked where own)
 select jsonb_build_object('total',(select count(*) from ranked),'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no) from ranked r where row_no<=20 or own),'[]'::jsonb)) into result;
 return result;
end $$;
revoke all on function public.endless_submit(text,boolean,text,integer,integer,integer,integer) from public,anon;
revoke all on function public.endless_leaderboard(text,boolean) from public,anon;
grant execute on function public.endless_submit(text,boolean,text,integer,integer,integer,integer) to authenticated;
grant execute on function public.endless_leaderboard(text,boolean) to authenticated;
