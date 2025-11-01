-- =====================================================
-- EcoSustain Database Migration Script
-- Migration: Recycle → Disposal Terminology
-- Date: November 1, 2025
-- =====================================================

-- This script migrates the database from "recycle/recycling" 
-- terminology to "dispose/disposal" terminology.
-- 
-- BACKUP YOUR DATABASE BEFORE RUNNING THIS SCRIPT!

BEGIN;

-- =====================================================
-- 1. RENAME TABLES
-- =====================================================

-- Rename recycling_history table to disposal_history
ALTER TABLE IF EXISTS recycling_history 
RENAME TO disposal_history;

-- =====================================================
-- 2. RENAME COLUMNS
-- =====================================================

-- Rename recycled_date to disposed_date in disposal_history table
ALTER TABLE disposal_history 
RENAME COLUMN recycled_date TO disposed_date;

-- Rename total_recycled to total_disposed in user_profiles table
ALTER TABLE user_profiles 
RENAME COLUMN total_recycled TO total_disposed;

-- =====================================================
-- 3. UPDATE INDEXES (if any exist)
-- =====================================================

-- Drop old index if it exists
DROP INDEX IF EXISTS idx_recycling_history_user_id;
DROP INDEX IF EXISTS idx_recycling_history_recycled_date;

-- Create new indexes with updated names
CREATE INDEX IF NOT EXISTS idx_disposal_history_user_id 
ON disposal_history(user_id);

CREATE INDEX IF NOT EXISTS idx_disposal_history_disposed_date 
ON disposal_history(disposed_date DESC);

-- =====================================================
-- 4. UPDATE FOREIGN KEY CONSTRAINTS (if any exist)
-- =====================================================

-- Note: Rename constraints if they reference the old table name
-- Example (adjust based on your actual constraints):

-- ALTER TABLE disposal_history 
-- RENAME CONSTRAINT fk_recycling_history_user_id 
-- TO fk_disposal_history_user_id;

-- =====================================================
-- 5. UPDATE VIEWS (if any exist)
-- =====================================================

-- Drop and recreate any views that reference the old table/column names
-- Example:
-- DROP VIEW IF EXISTS user_recycling_stats;
-- CREATE VIEW user_disposal_stats AS ...

-- =====================================================
-- 6. VERIFY CHANGES
-- =====================================================

-- Check that the table was renamed
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'disposal_history'
  ) THEN
    RAISE NOTICE '✅ Table renamed successfully: disposal_history';
  ELSE
    RAISE WARNING '❌ Table disposal_history not found!';
  END IF;
END $$;

-- Check that columns were renamed
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'disposal_history' 
    AND column_name = 'disposed_date'
  ) THEN
    RAISE NOTICE '✅ Column renamed successfully: disposed_date';
  ELSE
    RAISE WARNING '❌ Column disposed_date not found in disposal_history!';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name = 'total_disposed'
  ) THEN
    RAISE NOTICE '✅ Column renamed successfully: total_disposed';
  ELSE
    RAISE WARNING '❌ Column total_disposed not found in user_profiles!';
  END IF;
END $$;

COMMIT;

-- =====================================================
-- ROLLBACK SCRIPT (In case you need to revert)
-- =====================================================
-- 
-- Run this if you need to undo the migration:
-- 
-- BEGIN;
-- ALTER TABLE disposal_history RENAME TO recycling_history;
-- ALTER TABLE disposal_history RENAME COLUMN disposed_date TO recycled_date;
-- ALTER TABLE user_profiles RENAME COLUMN total_disposed TO total_recycled;
-- DROP INDEX IF EXISTS idx_disposal_history_user_id;
-- DROP INDEX IF EXISTS idx_disposal_history_disposed_date;
-- CREATE INDEX idx_recycling_history_user_id ON recycling_history(user_id);
-- CREATE INDEX idx_recycling_history_recycled_date ON recycling_history(recycled_date DESC);
-- COMMIT;
--
-- =====================================================

-- Post-Migration Verification Queries
-- Run these to verify the migration was successful:

-- 1. Check table structure
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'disposal_history'
-- ORDER BY ordinal_position;

-- 2. Check sample data
-- SELECT * FROM disposal_history LIMIT 5;

-- 3. Check user profiles
-- SELECT id, name, total_disposed FROM user_profiles LIMIT 5;

-- 4. Verify indexes
-- SELECT indexname FROM pg_indexes WHERE tablename = 'disposal_history';
