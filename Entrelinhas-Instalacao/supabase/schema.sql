-- Rode este arquivo uma vez no SQL Editor do projeto Supabase.
-- Os arquivos ficam em buckets privados; cada pessoa acessa só o que está na própria pasta.

create table if not exists public.books (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  author text not null default '',
  format text not null check (format in ('epub', 'pdf')),
  file_path text not null,
  file_name text not null,
  file_type text not null,
  file_size bigint not null check (file_size > 0),
  cover_path text,
  cover_type text,
  progress integer not null default 0 check (progress between 0 and 100),
  cfi text,
  page integer not null default 1 check (page >= 1),
  added_at bigint not null,
  updated_at bigint not null
);

create index if not exists books_user_added_idx
  on public.books (user_id, added_at desc);

alter table public.books enable row level security;
revoke all on table public.books from anon, authenticated;
grant select, insert, update, delete on table public.books to authenticated;

drop policy if exists "Users read their own books" on public.books;
create policy "Users read their own books"
  on public.books for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users add books to their own library" on public.books;
create policy "Users add books to their own library"
  on public.books for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users update their own books" on public.books;
create policy "Users update their own books"
  on public.books for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users delete their own books" on public.books;
create policy "Users delete their own books"
  on public.books for delete to authenticated
  using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('ebooks', 'ebooks', false, 52428800, array['application/epub+zip', 'application/pdf', 'application/octet-stream']),
  ('covers', 'covers', false, 8388608, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users read their own ebook files" on storage.objects;
create policy "Users read their own ebook files"
  on storage.objects for select to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Users upload their own ebook files" on storage.objects;
create policy "Users upload their own ebook files"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Users delete their own ebook files" on storage.objects;
create policy "Users delete their own ebook files"
  on storage.objects for delete to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Users read their own covers" on storage.objects;
create policy "Users read their own covers"
  on storage.objects for select to authenticated
  using (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Users upload their own covers" on storage.objects;
create policy "Users upload their own covers"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Users delete their own covers" on storage.objects;
create policy "Users delete their own covers"
  on storage.objects for delete to authenticated
  using (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);
