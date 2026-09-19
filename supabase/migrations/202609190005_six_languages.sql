-- Add word languages without splitting the shared leaderboards or changing old runs.
begin;
alter table public.daily_challenges drop constraint daily_challenges_language_check;
alter table public.daily_challenges add constraint daily_challenges_language_check check(language in ('en','de','fr','es','it','sr'));
alter table public.daily_attempts drop constraint daily_attempts_language_check;
alter table public.daily_attempts add constraint daily_attempts_language_check check(language in ('en','de','fr','es','it','sr'));
alter table public.endless_scores drop constraint endless_scores_language_check;
alter table public.endless_scores add constraint endless_scores_language_check check(language in ('en','de','fr','es','it','sr'));
alter table public.endless_runs drop constraint endless_runs_language_check;
alter table public.endless_runs add constraint endless_runs_language_check check(language in ('en','de','fr','es','it','sr'));
commit;
