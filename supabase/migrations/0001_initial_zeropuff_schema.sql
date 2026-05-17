-- ZeroPuff initial schema.
-- Run this in Supabase SQL editor before wiring real auth.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  avatar_url text,
  quit_date timestamptz,
  cigarettes_per_day integer not null default 0,
  pack_price numeric(10, 2) not null default 0,
  pack_size integer not null default 20,
  currency_code text not null default 'USD',
  currency_symbol text not null default '$',
  triggers text[] not null default '{}',
  quit_reason text,
  onboarding_completed boolean not null default false,
  subscription_tier text not null default 'free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.craving_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  intensity integer not null check (intensity between 1 and 10),
  triggers text[] not null default '{}',
  started_at timestamptz not null,
  completed_at timestamptz,
  outcome text not null default 'unknown'
    check (outcome in ('unknown', 'resisted', 'smoked', 'still_craving')),
  created_at timestamptz not null default now()
);

create table if not exists public.smoking_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  smoked_at timestamptz not null,
  count integer not null default 1 check (count > 0),
  trigger text not null default 'other',
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.daily_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  local_date date not null,
  mood integer not null check (mood between 1 and 5),
  smoke_free_today boolean not null default true,
  cigarettes_smoked integer not null default 0 check (cigarettes_smoked >= 0),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, local_date)
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_key text not null,
  unlocked_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, achievement_key)
);

create table if not exists public.notification_preferences (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  daily_checkin_enabled boolean not null default true,
  daily_checkin_time time not null default '21:00',
  milestone_reminder_enabled boolean not null default true,
  streak_protection_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  event_name text not null,
  properties jsonb not null default '{}',
  created_at timestamptz not null default now()
);

-- Future-version tables created early to avoid disruptive live migrations.
create table if not exists public.quit_circles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.circle_members (
  id uuid primary key default gen_random_uuid(),
  circle_id uuid not null references public.quit_circles(id) on delete cascade,
  name text not null,
  email text not null,
  status text not null default 'pending',
  notification_level text not null default 'sos_only',
  created_at timestamptz not null default now()
);

create table if not exists public.sos_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  circle_id uuid references public.quit_circles(id) on delete set null,
  message text,
  trigger_type text,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_chat_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  session_type text not null default 'freeform',
  created_at timestamptz not null default now()
);

create table if not exists public.ai_chat_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.ai_chat_sessions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_memory (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  memory jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

create table if not exists public.usage_tracking (
  user_id uuid not null references public.profiles(id) on delete cascade,
  tracking_date date not null,
  ai_messages_today integer not null default 0,
  ai_sessions_today integer not null default 0,
  primary key (user_id, tracking_date)
);

alter table public.profiles enable row level security;
alter table public.craving_logs enable row level security;
alter table public.smoking_logs enable row level security;
alter table public.daily_checkins enable row level security;
alter table public.achievements enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.app_events enable row level security;
alter table public.quit_circles enable row level security;
alter table public.circle_members enable row level security;
alter table public.sos_events enable row level security;
alter table public.ai_chat_sessions enable row level security;
alter table public.ai_chat_messages enable row level security;
alter table public.ai_memory enable row level security;
alter table public.usage_tracking enable row level security;

create policy "Profiles are user owned"
on public.profiles for all
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "Craving logs are user owned"
on public.craving_logs for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Smoking logs are user owned"
on public.smoking_logs for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Daily checkins are user owned"
on public.daily_checkins for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Achievements are user owned"
on public.achievements for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Notification preferences are user owned"
on public.notification_preferences for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "App events are user owned"
on public.app_events for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Quit circles are owner managed"
on public.quit_circles for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

create policy "AI sessions are user owned"
on public.ai_chat_sessions for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "AI messages are user owned"
on public.ai_chat_messages for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "AI memory is user owned"
on public.ai_memory for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Usage tracking is user owned"
on public.usage_tracking for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
