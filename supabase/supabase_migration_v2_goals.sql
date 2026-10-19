-- ============================================================
-- Cal-CMU Goal Loop Migration (v2)
-- Run AFTER the initial migration in Supabase SQL Editor
-- ============================================================

-- 1. Add weekend plan columns + weight goal to user_profiles
alter table public.user_profiles
    add column if not exists use_weekend_plan boolean not null default false,
    add column if not exists weekend_calorie_goal int not null default 2200,
    add column if not exists weekend_protein_goal double precision not null default 130,
    add column if not exists weekend_carbs_goal double precision not null default 280,
    add column if not exists weekend_fat_goal double precision not null default 75,
    add column if not exists target_weight double precision,
    add column if not exists weight_goal_type text not null default 'maintain';
    -- weight_goal_type: 'lose', 'gain', 'maintain'

-- 2. WEIGHT LOGS — one entry per day
create table if not exists public.weight_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null default current_date,
    weight double precision not null,
    created_at timestamptz not null default now(),
    unique(user_id, date)
);

alter table public.weight_logs enable row level security;

create policy "Users can read own weight logs"
    on public.weight_logs for select
    using (auth.uid() = user_id);

create policy "Users can insert own weight logs"
    on public.weight_logs for insert
    with check (auth.uid() = user_id);

create policy "Users can update own weight logs"
    on public.weight_logs for update
    using (auth.uid() = user_id);

create policy "Users can delete own weight logs"
    on public.weight_logs for delete
    using (auth.uid() = user_id);

create index if not exists idx_weight_logs_user_date on public.weight_logs(user_id, date desc);
