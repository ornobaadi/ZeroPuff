create table if not exists public.user_smoking_windows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text not null default 'usual',
  start_time time not null,
  end_time time not null,
  days_of_week integer[] not null default '{1,2,3,4,5,6,7}',
  enabled boolean not null default true,
  is_primary boolean not null default true,
  source text not null default 'onboarding',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint user_smoking_windows_label_check
    check (length(trim(label)) > 0),

  constraint user_smoking_windows_days_check
    check (
      array_length(days_of_week, 1) is not null
      and days_of_week <@ array[1,2,3,4,5,6,7]
    )
);

alter table public.user_smoking_windows enable row level security;

drop policy if exists "Smoking windows are user owned"
on public.user_smoking_windows;

create policy "Smoking windows are user owned"
on public.user_smoking_windows for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create unique index if not exists user_smoking_windows_one_primary_per_user
on public.user_smoking_windows (user_id)
where is_primary = true;

alter table public.notification_preferences
add column if not exists danger_window_enabled boolean not null default true;
