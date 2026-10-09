-- Sealing the day stores what helped or what made it hard, and no longer
-- requires a mood to be given.

alter table public.daily_checkins
  add column if not exists tags text[] not null default '{}';

alter table public.daily_checkins
  alter column mood drop not null;
