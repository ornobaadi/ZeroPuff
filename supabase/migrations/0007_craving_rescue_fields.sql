-- The rebuilt rescue records how the urge changed, which tools were used and
-- how many breaths were taken, and can end without an answer.

alter table public.craving_logs
  add column if not exists intensity_after integer
    check (intensity_after between 1 and 10),
  add column if not exists tools_used text[] not null default '{}',
  add column if not exists breaths integer not null default 0
    check (breaths >= 0);

alter table public.craving_logs
  drop constraint if exists craving_logs_outcome_check;

alter table public.craving_logs
  add constraint craving_logs_outcome_check
  check (outcome in ('unknown', 'resisted', 'smoked', 'still_craving', 'abandoned'));
