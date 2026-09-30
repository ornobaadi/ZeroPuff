-- Hardening pass (run after 0004 and 0005).

-- 1. delete_my_account: empty search_path so nothing can be shadowed.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- 2. Bound the size of client-written analytics events.
--    NOT VALID keeps existing rows untouched while enforcing new writes.
alter table public.app_events
  drop constraint if exists app_events_event_name_length,
  drop constraint if exists app_events_properties_size;
alter table public.app_events
  add constraint app_events_event_name_length
    check (char_length(event_name) between 1 and 64) not valid,
  add constraint app_events_properties_size
    check (octet_length(properties::text) <= 4096) not valid;

-- 3. Users must not be able to grant themselves a subscription tier.
create or replace function public.protect_subscription_tier()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if coalesce(auth.role(), '') <> 'service_role' then
      new.subscription_tier := 'free';
    end if;
  elsif new.subscription_tier is distinct from old.subscription_tier
        and coalesce(auth.role(), '') <> 'service_role' then
    new.subscription_tier := old.subscription_tier;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_subscription_tier on public.profiles;
create trigger protect_subscription_tier
  before insert or update on public.profiles
  for each row execute function public.protect_subscription_tier();
