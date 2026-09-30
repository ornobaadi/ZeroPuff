-- Removes tables for features that are not part of ZeroPuff (AI chat, quit
-- circles / community, usage metering). None are referenced by the app.
-- Review before applying; this permanently deletes any data in these tables.
drop table if exists public.ai_chat_messages cascade;
drop table if exists public.ai_chat_sessions cascade;
drop table if exists public.ai_memory cascade;
drop table if exists public.usage_tracking cascade;
drop table if exists public.sos_events cascade;
drop table if exists public.circle_members cascade;
drop table if exists public.quit_circles cascade;
