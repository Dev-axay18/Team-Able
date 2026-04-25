-- ============================================================
--  Run this in Supabase SQL Editor
--  Adds bed category columns to the hospitals table
-- ============================================================

ALTER TABLE public.hospitals
  ADD COLUMN IF NOT EXISTS general_ward_beds     integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS private_room_beds     integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pediatric_beds        integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS maternity_beds        integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS isolation_beds        integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS burn_unit_beds        integer NOT NULL DEFAULT 0;

-- Verify the columns were added
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'hospitals'
ORDER BY ordinal_position;
