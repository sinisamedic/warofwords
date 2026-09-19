begin;
-- Preserve known best scores from clients predating per-run storage.
insert into endless_runs(user_id,run_id,language,adjacent,nickname,score,wave,words,seconds,created_at)
select s.user_id,md5('legacy:'||s.user_id::text||':'||s.language||':'||s.adjacent::text)::uuid,
s.language,s.adjacent,s.nickname,s.score,s.wave,s.words,s.seconds,s.updated_at
from endless_scores s where not exists (
 select 1 from endless_runs r where r.user_id=s.user_id and r.language=s.language
 and r.adjacent=s.adjacent and r.score=s.score
) on conflict(user_id,run_id) do nothing;

create function public.endless_attempt_leaderboard(p_adjacent boolean,p_run uuid default null)
returns jsonb language plpgsql stable security definer set search_path=public as $$
declare result jsonb;
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_adjacent is null then raise exception 'Invalid category'; end if;
 with ranked as (
 select nickname,score,wave,words,user_id=auth.uid() as own,
 coalesce(user_id=auth.uid() and run_id=p_run,false) as current,
 rank() over(order by score desc) as position,
 row_number() over(order by score desc,created_at,user_id,run_id) as row_no
 from endless_runs where adjacent=p_adjacent
 ), anchor as (select row_no from ranked where current)
 select jsonb_build_object('total',(select count(*) from ranked),
 'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no) from ranked r
 where row_no<=10 or row_no between (select row_no-2 from anchor) and (select row_no from anchor)),'[]'::jsonb)) into result;
 return result;
end $$;
revoke all on function public.endless_attempt_leaderboard(boolean,uuid) from public,anon;
grant execute on function public.endless_attempt_leaderboard(boolean,uuid) to authenticated;
-- A retry after a lost response can correct the name without changing the score.
create or replace function public.endless_finish(p_run uuid,p_language text,p_adjacent boolean,p_nickname text,p_score integer,p_wave integer,p_words integer,p_seconds integer)
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
 update endless_runs set nickname=trim(p_nickname) where user_id=auth.uid() and run_id=p_run;
 return jsonb_build_object('saved',true);
end $$;
commit;
