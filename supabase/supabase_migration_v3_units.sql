-- Migration V3: Unit system + weight goal pace/timeframe
-- Run this in Supabase Dashboard → SQL Editor

-- Add unit system preference
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS unit_system TEXT NOT NULL DEFAULT 'imperial';

-- Add weight goal pace and timeframe
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS weight_goal_pace DOUBLE PRECISION DEFAULT 1.0,
  ADD COLUMN IF NOT EXISTS weight_goal_timeframe TEXT DEFAULT 'weekly';

-- Add comments for documentation
COMMENT ON COLUMN user_profiles.unit_system IS 'imperial or metric';
COMMENT ON COLUMN user_profiles.weight_goal_pace IS 'Target weight change per timeframe in lbs (stored as imperial internally)';
COMMENT ON COLUMN user_profiles.weight_goal_timeframe IS 'weekly or monthly';
