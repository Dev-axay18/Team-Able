-- Run this entire block in Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → paste → Run

-- Step 1: Enable RLS on both tables (required before policies work)
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambulance_drivers ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop any existing conflicting policies (safe to run even if they don't exist)
DROP POLICY IF EXISTS "Allow public read" ON hospitals;
DROP POLICY IF EXISTS "Allow public update" ON hospitals;
DROP POLICY IF EXISTS "Allow public read" ON ambulance_drivers;
DROP POLICY IF EXISTS "Allow public update" ON ambulance_drivers;

-- Step 3: Create fresh policies
CREATE POLICY "Allow public read"   ON hospitals         FOR SELECT USING (true);
CREATE POLICY "Allow public update" ON hospitals         FOR UPDATE USING (true);
CREATE POLICY "Allow public read"   ON ambulance_drivers FOR SELECT USING (true);
CREATE POLICY "Allow public update" ON ambulance_drivers FOR UPDATE USING (true);
