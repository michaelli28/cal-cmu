-- ============================================================
-- Cal-CMU Migration v4 — Restaurant Menu Items
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. RESTAURANT MENU ITEMS TABLE
-- Stores nutrition data for items at CMU dining locations
create table if not exists public.restaurant_menu_items (
    id uuid primary key default gen_random_uuid(),
    restaurant text not null,
    item_name text not null,
    category text not null default 'entree',
    calories int not null default 0,
    calories_from_fat int not null default 0,
    total_fat_g double precision not null default 0,
    sat_fat_g double precision not null default 0,
    trans_fat_g double precision not null default 0,
    cholesterol_mg double precision not null default 0,
    sodium_mg double precision not null default 0,
    carbs_g double precision not null default 0,
    fiber_g double precision not null default 0,
    sugars_g double precision not null default 0,
    protein_g double precision not null default 0,
    vitamin_a_pct int not null default 0,
    vitamin_c_pct int not null default 0,
    calcium_pct int not null default 0,
    iron_pct int not null default 0,
    created_at timestamptz not null default now(),

    -- prevent duplicate entries
    unique(restaurant, item_name)
);

-- 2. RLS POLICIES
-- Menu items are public/read-only for all authenticated users
alter table public.restaurant_menu_items enable row level security;

create policy "Anyone can read menu items"
    on public.restaurant_menu_items
    for select
    using (true);

-- 3. INDEX for fast restaurant filtering
create index if not exists idx_restaurant_menu_items_restaurant
    on public.restaurant_menu_items (restaurant);

-- 4. SEED DATA — The Exchange at CMU
insert into public.restaurant_menu_items
    (restaurant, item_name, category, calories, calories_from_fat, total_fat_g, sat_fat_g, trans_fat_g, cholesterol_mg, sodium_mg, carbs_g, fiber_g, sugars_g, protein_g, vitamin_a_pct, vitamin_c_pct, calcium_pct, iron_pct)
values
    ('The Exchange', 'Breakfast Sandwich (English Muffin)', 'breakfast', 520, 270, 30.0, 12.0, 0.0, 600, 1380, 27, 3, 1, 39, 15, 0, 35, 10),
    ('The Exchange', 'Breakfast Sandwich (Croissant BEC)', 'breakfast', 660, 390, 43.0, 20.0, 0.0, 645, 1400, 32, 2, 8, 39, 25, 0, 30, 10),
    ('The Exchange', 'Chicken Salad', 'salad', 240, 80, 9.0, 2.0, 0.0, 100, 870, 4, 0, 1, 35, 2, 0, 2, 6),
    ('The Exchange', 'Fruit', 'side', 70, 0, 0.0, 0.0, 0.0, 0, 15, 19, 2, 15, 1, 25, 35, 0, 2),
    ('The Exchange', 'Potato Salad', 'side', 100, 20, 2.0, 0.0, 0.0, 0, 125, 19, 2, 0, 3, 0, 20, 4, 8),
    ('The Exchange', 'Standard Salad', 'salad', 140, 35, 4.0, 2.0, 0.0, 25, 580, 16, 5, 4, 13, 100, 60, 20, 20),
    ('The Exchange', 'Tuna Salad', 'salad', 290, 140, 16.0, 2.5, 0.0, 100, 630, 4, 0, 1, 32, 2, 4, 2, 6),
    ('The Exchange', 'Asian Noodle Salad', 'salad', 340, 35, 4.0, 1.5, 0.0, 65, 110, 62, 3, 3, 14, 2, 4, 4, 15),
    ('The Exchange', 'Bowtie Pasta', 'entree', 340, 30, 3.5, 0.5, 0.0, 0, 400, 65, 3, 4, 12, 0, 2, 2, 15),
    ('The Exchange', 'Build a Burger', 'entree', 700, 370, 41.0, 18.0, 2.0, 185, 690, 24, 1, 2, 55, 10, 4, 30, 35),
    ('The Exchange', 'Beef Stroganoff', 'entree', 220, 90, 10.0, 4.0, 0.0, 80, 500, 4, 1, 2, 27, 2, 2, 2, 15),
    ('The Exchange', 'Chicken Cacciatore w Noodles', 'entree', 250, 60, 6.0, 2.5, 0.0, 90, 250, 24, 1, 2, 22, 25, 2, 2, 10),
    ('The Exchange', 'Cod w Tomato Sauce & Wild Rice', 'entree', 380, 100, 11.0, 4.0, 0.0, 135, 790, 36, 3, 4, 35, 110, 25, 6, 15),
    ('The Exchange', 'Jambalaya Cajun Rice', 'entree', 360, 100, 11.0, 3.0, 0.0, 120, 1940, 34, 1, 1, 31, 2, 10, 2, 10),
    ('The Exchange', 'Chicken Fingers w Mac & Cheese', 'entree', 640, 310, 35.0, 9.0, 0.0, 85, 1520, 47, 3, 1, 33, 4, 0, 10, 15),
    ('The Exchange', 'Meatloaf w Mashed Potatoes', 'entree', 530, 230, 26.0, 11.0, 1.5, 125, 960, 35, 3, 4, 35, 10, 40, 6, 20),
    ('The Exchange', 'Baked Chicken & Perogies', 'entree', 520, 180, 21.0, 10.0, 0.0, 100, 810, 23, 2, 6, 57, 8, 2, 4, 15),
    ('The Exchange', 'Rosemary Pork Loin w Kielbasa', 'entree', 470, 150, 17.0, 5.0, 0.0, 115, 2040, 39, 2, 1, 39, 2, 10, 2, 15),
    ('The Exchange', 'Swedish Meatballs w Noodles', 'entree', 450, 230, 26.0, 9.0, 1.5, 120, 470, 20, 2, 1, 33, 2, 2, 8, 20),
    ('The Exchange', 'Standard Sandwich (White Bread)', 'sandwich', 450, 160, 18.0, 10.0, 0.0, 80, 1250, 36, 2, 9, 36, 50, 25, 45, 15),
    ('The Exchange', 'Broccoli & Bacon Salad', 'salad', 80, 40, 4.5, 1.0, 0.0, 5, 170, 9, 4, 2, 3, 35, 120, 6, 4),
    ('The Exchange', 'Egg Salad', 'salad', 240, 160, 17.0, 4.5, 0.0, 600, 550, 4, 0, 2, 19, 15, 0, 8, 15)
on conflict (restaurant, item_name) do nothing;
