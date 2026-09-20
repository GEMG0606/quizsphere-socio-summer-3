-- =====================================================================
--  QuizSphere: lock the database after the event (read-only archive)
--
--  Run in Supabase > SQL Editor > New query > paste > Run.
--  Safe to run again.
--
--  After this runs:
--    * Visitors can still read the leaderboards, players, announcements,
--      posters and everything else the public site shows.
--    * Nobody using the public key can change or delete anything.
--    * The feedback rows (keys starting with "feedback_") can no longer
--      be read with the public key.
--    * You can still see and edit everything in the Supabase dashboard
--      (Table Editor), which is not affected by these rules.
--
--  Consequence: the site's admin panel cannot save changes and the
--  feedback form cannot submit any more. That is intended for a finished
--  event. See "RE-OPEN" at the bottom if you ever need it again.
-- =====================================================================

alter table public.quizsphere enable row level security;

-- Remove every existing policy first. An old "allow everything" policy
-- would silently keep the table open, so this file starts from clean.
do $$
declare
  p record;
begin
  for p in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'quizsphere'
  loop
    execute format('drop policy if exists %I on public.quizsphere', p.policyname);
  end loop;
end
$$;

-- The only rule: everyone may read, except the feedback rows.
create policy "Public can read results (not feedback)"
  on public.quizsphere
  for select
  to anon, authenticated
  using (key not like 'feedback\_%');

-- Belt and braces: remove write permissions as well.
revoke insert, update, delete, truncate on public.quizsphere from anon, authenticated;
grant select on public.quizsphere to anon, authenticated;

-- Check: rls_enabled should be true, and there should be exactly one
-- policy, a SELECT one.
select relrowsecurity as rls_enabled
from pg_class
where oid = 'public.quizsphere'::regclass;

select policyname, cmd, roles
from pg_policies
where schemaname = 'public' and tablename = 'quizsphere';

-- ---------------------------------------------------------------------
-- OPTIONAL: delete the participant feedback for good.
-- Download it first from the admin panel (feedback CSV), because this
-- cannot be undone. Remove the leading dashes to use it.
-- ---------------------------------------------------------------------
-- delete from public.quizsphere where key like 'feedback\_%';

-- ---------------------------------------------------------------------
-- RE-OPEN: only if you run another live event with this app as built.
-- The admin panel and feedback form write with the public key, so this
-- lets anyone who has that key edit the data. Remove the dashes to use it.
-- ---------------------------------------------------------------------
-- alter table public.quizsphere disable row level security;
-- grant insert, update, delete on public.quizsphere to anon, authenticated;
