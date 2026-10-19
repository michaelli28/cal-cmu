-- Migration: Add user_gender column to user_profiles
-- Run this in the Supabase SQL Editor

ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS user_gender text NOT NULL DEFAULT 'male';
