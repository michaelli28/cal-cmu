-- Migration: Add has_completed_onboarding column to user_profiles
-- Run this in the Supabase SQL Editor

ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS has_completed_onboarding boolean NOT NULL DEFAULT false;
