-- ============================================================
-- Cal-CMU Supabase Migration
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. USER PROFILES
-- Stores user settings & profile info, linked to auth.users
create table if not exists public.user_profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    user_name text not null default '',
    user_age int not null default 22,
    user_weight double precision not null default 165,
    user_height double precision not null default 72,
    daily_calorie_goal int not null default 2000,
    daily_protein_goal double precision not null default 150,
    daily_carbs_goal double precision not null default 250,
    daily_fat_goal double precision not null default 65,
    streak_days int not null default 0,
    show_notifications boolean not null default true,
    use_dark_mode boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 2. MEALS
-- Stores all meal entries per user
create table if not exists public.meals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    meal_type text not null default 'Lunch',
    scan_source text not null default 'Photo',
    timestamp timestamptz not null default now(),
    calories int not null default 0,
    protein double precision not null default 0,
    carbs double precision not null default 0,
    fat double precision not null default 0,
    fiber double precision not null default 0,
    sugar double precision not null default 0,
    sodium double precision not null default 0,
    vitamin_c double precision not null default 0,
    vitamin_b6 double precision not null default 0,
    vitamin_b12 double precision not null default 0,
    vitamin_d double precision not null default 0,
    vitamin_a double precision not null default 0,
    potassium double precision not null default 0,
    iron double precision not null default 0,
    calcium double precision not null default 0,
    magnesium double precision not null default 0,
    zinc double precision not null default 0,
    receipt_items jsonb not null default '[]'::jsonb,
    restaurant_name text,
    image_url text,
    created_at timestamptz not null default now()
);

-- 3. WATER LOGS
-- One row per user per day for water tracking
create table if not exists public.water_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null default current_date,
    intake int not null default 0,
    goal int not null default 8,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique(user_id, date)
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Users can only access their own data
-- ============================================================

alter table public.user_profiles enable row level security;
alter table public.meals enable row level security;
alter table public.water_logs enable row level security;

-- user_profiles policies
create policy "Users can read own profile"
    on public.user_profiles for select
    using (auth.uid() = id);

create policy "Users can insert own profile"
    on public.user_profiles for insert
    with check (auth.uid() = id);

create policy "Users can update own profile"
    on public.user_profiles for update
    using (auth.uid() = id);

-- meals policies
create policy "Users can read own meals"
    on public.meals for select
    using (auth.uid() = user_id);

create policy "Users can insert own meals"
    on public.meals for insert
    with check (auth.uid() = user_id);

create policy "Users can update own meals"
    on public.meals for update
    using (auth.uid() = user_id);

create policy "Users can delete own meals"
    on public.meals for delete
    using (auth.uid() = user_id);

-- water_logs policies
create policy "Users can read own water logs"
    on public.water_logs for select
    using (auth.uid() = user_id);

create policy "Users can insert own water logs"
    on public.water_logs for insert
    with check (auth.uid() = user_id);

create policy "Users can update own water logs"
    on public.water_logs for update
    using (auth.uid() = user_id);

-- ============================================================
-- INDEXES for performance
-- ============================================================

create index if not exists idx_meals_user_id on public.meals(user_id);
create index if not exists idx_meals_user_timestamp on public.meals(user_id, timestamp desc);
create index if not exists idx_water_logs_user_date on public.water_logs(user_id, date);

-- ============================================================
-- AUTO-CREATE PROFILE on sign up (trigger)
-- ============================================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.user_profiles (id)
    values (new.id);
    return new;
end;
$$ language plpgsql security definer;

-- Drop if exists to make re-runs safe
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- ============================================================
-- STORAGE BUCKET for meal images
-- ============================================================

insert into storage.buckets (id, name, public)
values ('meal-images', 'meal-images', true)
on conflict (id) do nothing;

-- Storage policies: users can upload to their own folder
create policy "Users can upload meal images"
    on storage.objects for insert
    with check (
        bucket_id = 'meal-images'
        and auth.uid()::text = (storage.foldername(name))[1]
    );

create policy "Anyone can view meal images"
    on storage.objects for select
    using (bucket_id = 'meal-images');

create policy "Users can delete own meal images"
    on storage.objects for delete
    using (
        bucket_id = 'meal-images'
        and auth.uid()::text = (storage.foldername(name))[1]
    );
