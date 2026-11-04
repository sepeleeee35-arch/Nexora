-- Nexora Chat schema. Run once in Supabase SQL Editor.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  display_name text not null default '',
  avatar_url text,
  created_at timestamptz not null default now()
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'direct' check (kind in ('direct')),
  created_at timestamptz not null default now()
);
create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key(conversation_id,user_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now()
);
create index if not exists messages_conversation_created_idx on public.messages(conversation_id,created_at);
alter table public.profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
drop policy if exists "profiles visible to signed in users" on public.profiles;
create policy "profiles visible to signed in users" on public.profiles for select to authenticated using (true);
drop policy if exists "users manage own profile" on public.profiles;
create policy "users manage own profile" on public.profiles for insert to authenticated with check (id=auth.uid());
drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
drop policy if exists "members read conversations" on public.conversations;
create policy "members read conversations" on public.conversations for select to authenticated using (
 exists(select 1 from public.conversation_members m where m.conversation_id=id and m.user_id=auth.uid())
);
drop policy if exists "members read memberships" on public.conversation_members;
create policy "members read memberships" on public.conversation_members for select to authenticated using (
 exists(select 1 from public.conversation_members m where m.conversation_id=conversation_id and m.user_id=auth.uid())
);
drop policy if exists "members read messages" on public.messages;
create policy "members read messages" on public.messages for select to authenticated using (
 exists(select 1 from public.conversation_members m where m.conversation_id=conversation_id and m.user_id=auth.uid())
);
drop policy if exists "members send messages" on public.messages;
create policy "members send messages" on public.messages for insert to authenticated with check (
 sender_id=auth.uid() and exists(select 1 from public.conversation_members m where m.conversation_id=conversation_id and m.user_id=auth.uid())
);
create or replace function public.create_direct_conversation(other_user uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare existing_id uuid; new_id uuid;
begin
 if auth.uid() is null or other_user=auth.uid() then raise exception 'Invalid user'; end if;
 if not exists(select 1 from public.profiles where id=other_user) then raise exception 'User not found'; end if;
 select c.id into existing_id from public.conversations c
 join public.conversation_members a on a.conversation_id=c.id and a.user_id=auth.uid()
 join public.conversation_members b on b.conversation_id=c.id and b.user_id=other_user
 where c.kind='direct'
 and (select count(*) from public.conversation_members x where x.conversation_id=c.id)=2 limit 1;
 if existing_id is not null then return existing_id; end if;
 insert into public.conversations(kind) values('direct') returning id into new_id;
 insert into public.conversation_members(conversation_id,user_id) values(new_id,auth.uid()),(new_id,other_user);
 return new_id;
end; $$;
revoke all on function public.create_direct_conversation(uuid) from public;
grant execute on function public.create_direct_conversation(uuid) to authenticated;
grant select,insert,update on public.profiles to authenticated;
grant select on public.conversations,public.conversation_members to authenticated;
grant select,insert on public.messages to authenticated;
alter publication supabase_realtime add table public.messages;
