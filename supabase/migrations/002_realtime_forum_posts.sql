-- Enable Realtime for forum_posts so the app can subscribe to new posts
-- (e.g. to notify users when someone posts on a favourited airfield).
-- Run this in Supabase SQL Editor after 001_profiles_forum.sql.
-- Alternatively: Dashboard → Database → Replication → add "forum_posts" to supabase_realtime.

alter publication supabase_realtime add table public.forum_posts;
