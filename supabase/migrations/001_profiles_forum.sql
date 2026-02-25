-- Runways App: profiles, forum_posts, forum_votes
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor) after creating your project.

-- =============================================================================
-- PROFILES (extends auth.users)
-- =============================================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text default '',
  email text default '',
  settings jsonb default '{"notificationsEnabled": true, "notifyNearAirfield": true, "locationForAirfieldsEnabled": false}'::jsonb,
  favourite_airfield_ids text[] default '{}',
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

alter table public.profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger: create profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, email, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', ''),
    coalesce(new.email, ''),
    now()
  )
  on conflict (id) do update set
    email = coalesce(excluded.email, profiles.email),
    updated_at = now();
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================================
-- FORUM POSTS (per-airfield community board)
-- =============================================================================
create table if not exists public.forum_posts (
  id uuid primary key default gen_random_uuid(),
  airfield_id text not null,
  author_id uuid not null references auth.users(id) on delete cascade,
  author_display_name text default '',
  content text not null,
  category text not null default 'general',
  thumbs_up int not null default 0,
  thumbs_down int not null default 0,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

create index if not exists idx_forum_posts_airfield_created
  on public.forum_posts(airfield_id, created_at desc);

alter table public.forum_posts enable row level security;

create policy "Authenticated users can read forum posts"
  on public.forum_posts for select
  to authenticated
  using (true);

create policy "Authenticated users can insert own post"
  on public.forum_posts for insert
  to authenticated
  with check (auth.uid() = author_id);

create policy "Authors can update own post"
  on public.forum_posts for update
  to authenticated
  using (auth.uid() = author_id);

create policy "Authors can delete own post"
  on public.forum_posts for delete
  to authenticated
  using (auth.uid() = author_id);

-- =============================================================================
-- FORUM VOTES (one vote per user per post)
-- =============================================================================
create table if not exists public.forum_votes (
  post_id uuid not null references public.forum_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  vote text not null check (vote in ('up', 'down')),
  updated_at timestamptz default now() not null,
  primary key (post_id, user_id)
);

alter table public.forum_votes enable row level security;

create policy "Users can read own votes"
  on public.forum_votes for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own vote"
  on public.forum_votes for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own vote"
  on public.forum_votes for update
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can delete own vote"
  on public.forum_votes for delete
  to authenticated
  using (auth.uid() = user_id);

-- Update forum_posts thumbs when a vote is added/updated/deleted
create or replace function public.sync_forum_post_votes()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  delta_up int := 0;
  delta_down int := 0;
  old_vote text;
  new_vote text;
begin
  if tg_op = 'DELETE' then
    old_vote := old.vote;
    if old_vote = 'up' then delta_up := -1; else delta_down := -1; end if;
  elsif tg_op = 'INSERT' then
    new_vote := new.vote;
    if new_vote = 'up' then delta_up := 1; else delta_down := 1; end if;
  else
    old_vote := old.vote;
    new_vote := new.vote;
    if old_vote = 'up' then delta_up := delta_up - 1; else delta_down := delta_down - 1; end if;
    if new_vote = 'up' then delta_up := delta_up + 1; else delta_down := delta_down + 1; end if;
  end if;

  update public.forum_posts
  set thumbs_up = thumbs_up + delta_up,
      thumbs_down = thumbs_down + delta_down,
      updated_at = now()
  where id = coalesce(new.post_id, old.post_id);
  return coalesce(new, old);
end;
$$;

create trigger on_forum_vote_change
  after insert or update or delete on public.forum_votes
  for each row execute function public.sync_forum_post_votes();
