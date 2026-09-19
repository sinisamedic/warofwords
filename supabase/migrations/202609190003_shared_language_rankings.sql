-- Keep language on attempts for replay, but rank each player's best across languages.
begin;
create or replace function public.endless_leaderboard(p_language text,p_adjacent boolean)
returns jsonb language plpgsql stable security definer set search_path=public as $$
declare result jsonb;
begin
 if auth.uid() is null then raise exception 'Sign in required'; end if;
 if p_adjacent is null then raise exception 'Invalid category'; end if;
 with best as (
 select distinct on (user_id) user_id,nickname,score,wave,words,updated_at
 from endless_scores where adjacent=p_adjacent
 order by user_id,score desc,updated_at,language
 ), ranked as (
 select nickname,score,wave,words,user_id=auth.uid() as own,
 rank() over(order by score desc) as position,
 row_number() over(order by score desc,updated_at,user_id) as row_no from best
 )
 select jsonb_build_object('total',(select count(*) from ranked),'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no) from ranked r where row_no<=20 or own),'[]'::jsonb)) into result;
 return result;
end $$;
create or replace function public.daily_leaderboard_versioned(p_user uuid,p_language text,p_adjacent boolean,p_version text)
returns jsonb language sql stable security definer set search_path=public as $$
 with best as (
 select distinct on (user_id) user_id,nickname,score,word_count,finished_at,id
 from daily_attempts
 where day=(now() at time zone 'UTC')::date and adjacent=p_adjacent
 and version=p_version and finished_at is not null
 order by user_id,score desc,finished_at,id
 ), ranked as (
 select nickname,score,word_count,user_id=p_user as own,
 rank() over(order by score desc) as position,
 row_number() over(order by score desc,finished_at,id) as row_no from best
 ), mine as (select row_no from ranked where own)
 select jsonb_build_object('day',(now() at time zone 'UTC')::date,
 'total',(select count(*) from ranked),
 'rows',coalesce((select jsonb_agg(to_jsonb(r)-'row_no' order by row_no) from ranked r
 where row_no<=20 or abs(row_no-(select row_no from mine))<=2),'[]'::jsonb));
$$;
create or replace function public.daily_leaderboard(p_user uuid,p_language text,p_adjacent boolean)
returns jsonb language sql stable security definer set search_path=public as $$
 select daily_leaderboard_versioned(p_user,p_language,p_adjacent,'daily-v1');
$$;
commit;
