-- ================================================================
-- StanDiag Auto — Full Database Schema
-- Run this in Supabase SQL Editor to set up the database
-- ================================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "postgis";

-- ================================================================
-- Drop existing tables (clean slate)
-- ================================================================
drop table if exists notifications cascade;
drop table if exists reviews cascade;
drop table if not exists scans cascade;
drop table if exists bookings cascade;
drop table if exists subscriptions cascade;
drop table if exists mechanic_profiles cascade;
drop table if exists vehicles cascade;
drop table if exists profiles cascade;

-- ================================================================
-- PROFILES
-- ================================================================
create table profiles (
  id            uuid primary key references auth.users on delete cascade,
  first_name    text not null default '',
  last_name     text not null default '',
  username      text unique,
  email         text not null default '',
  phone         text not null default '',
  gender        text,
  account_type  text not null check (account_type in ('car_owner','mechanic')),
  avatar_url    text,
  created_at    timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Users can view own profile"
  on profiles for select using (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert with check (auth.uid() = id);

create policy "Mechanics visible to all authenticated users"
  on profiles for select using (
    auth.role() = 'authenticated'
  );

-- ================================================================
-- VEHICLES
-- ================================================================
create table vehicles (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references profiles on delete cascade,
  make          text not null,
  model         text not null,
  year          int not null,
  engine_type   text not null,
  nickname      text,
  is_active     bool not null default true,
  created_at    timestamptz not null default now()
);

alter table vehicles enable row level security;

create policy "Users can manage own vehicles"
  on vehicles for all using (auth.uid() = user_id);

-- ================================================================
-- MECHANIC PROFILES
-- ================================================================
create table mechanic_profiles (
  id               uuid primary key references profiles on delete cascade,
  specialisations  text[] not null default '{}',
  experience_years int not null default 0,
  address          text,
  latitude         float,
  longitude        float,
  phone            text,
  bio              text,
  is_verified      bool not null default false,
  rating           float not null default 0.0,
  review_count     int not null default 0,
  profile_views    int not null default 0,
  created_at       timestamptz not null default now()
);

alter table mechanic_profiles enable row level security;

create policy "Mechanic profiles visible to all authenticated users"
  on mechanic_profiles for select using (auth.role() = 'authenticated');

create policy "Mechanics can update own profile"
  on mechanic_profiles for update using (auth.uid() = id);

create policy "Mechanics can insert own profile"
  on mechanic_profiles for insert with check (auth.uid() = id);

-- ================================================================
-- SUBSCRIPTIONS
-- ================================================================
create table subscriptions (
  id            uuid primary key default uuid_generate_v4(),
  mechanic_id   uuid not null references profiles on delete cascade,
  plan_type     text not null check (plan_type in ('standard','pro','unlimited')),
  slots_limit   int,  -- null = unlimited
  slots_used    int not null default 0,
  amount        int not null,
  status        text not null default 'active'
                check (status in ('active','expired','cancelled')),
  started_at    timestamptz not null default now(),
  expires_at    timestamptz not null,
  payment_ref   text,
  created_at    timestamptz not null default now()
);

alter table subscriptions enable row level security;

create policy "Mechanics can view own subscription"
  on subscriptions for select using (auth.uid() = mechanic_id);

create policy "Mechanics can insert own subscription"
  on subscriptions for insert with check (auth.uid() = mechanic_id);

-- ================================================================
-- BOOKINGS
-- ================================================================
create table bookings (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid not null references profiles on delete cascade,
  mechanic_id    uuid not null references profiles on delete cascade,
  vehicle_id     uuid references vehicles on delete set null,
  status         text not null default 'pending'
                 check (status in (
                   'pending','accepted','in_progress',
                   'completed','declined','cancelled'
                 )),
  created_at     timestamptz not null default now(),
  accepted_at    timestamptz,
  completed_at   timestamptz
);

alter table bookings enable row level security;

create policy "Users can view own bookings"
  on bookings for select using (
    auth.uid() = user_id or auth.uid() = mechanic_id
  );

create policy "Users can create bookings"
  on bookings for insert with check (auth.uid() = user_id);

create policy "Mechanic can update booking status"
  on bookings for update using (
    auth.uid() = mechanic_id or auth.uid() = user_id
  );

-- ================================================================
-- REVIEWS
-- ================================================================
create table reviews (
  id           uuid primary key default uuid_generate_v4(),
  booking_id   uuid not null references bookings on delete cascade,
  user_id      uuid not null references profiles on delete cascade,
  mechanic_id  uuid not null references profiles on delete cascade,
  rating       int not null check (rating between 1 and 5),
  comment      text,
  created_at   timestamptz not null default now(),
  unique (booking_id) -- one review per booking
);

alter table reviews enable row level security;

create policy "Reviews visible to all authenticated users"
  on reviews for select using (auth.role() = 'authenticated');

create policy "Users can insert review for own booking"
  on reviews for insert with check (auth.uid() = user_id);

-- ================================================================
-- SCANS
-- ================================================================
create table scans (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references profiles on delete cascade,
  vehicle_id  uuid references vehicles on delete set null,
  dtc_codes   text[] not null default '{}',
  ai_summary  text,
  severity    text not null default 'clear'
              check (severity in ('clear','warning','critical')),
  scanned_at  timestamptz not null default now()
);

alter table scans enable row level security;

create policy "Users can manage own scans"
  on scans for all using (auth.uid() = user_id);

-- ================================================================
-- NOTIFICATIONS
-- ================================================================
create table notifications (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references profiles on delete cascade,
  title       text not null,
  body        text not null,
  type        text not null,
  is_read     bool not null default false,
  data        jsonb,
  created_at  timestamptz not null default now()
);

alter table notifications enable row level security;

create policy "Users can manage own notifications"
  on notifications for all using (auth.uid() = user_id);

-- ================================================================
-- FUNCTIONS & TRIGGERS
-- ================================================================

-- Auto-increment profile_views when a user views a mechanic profile
create or replace function increment_profile_views(mechanic_uuid uuid)
returns void as $$
  update mechanic_profiles
  set profile_views = profile_views + 1
  where id = mechanic_uuid;
$$ language sql security definer;

-- Auto-increment slots_used when booking is accepted
create or replace function increment_slots_used()
returns trigger as $$
begin
  if NEW.status = 'accepted' and OLD.status = 'pending' then
    update subscriptions
    set slots_used = slots_used + 1
    where mechanic_id = NEW.mechanic_id
      and status = 'active'
      and (slots_limit is null or slots_used < slots_limit);
  end if;
  return NEW;
end;
$$ language plpgsql security definer;

create trigger on_booking_accepted
  after update on bookings
  for each row execute function increment_slots_used();

-- Update mechanic rating when a review is added
create or replace function update_mechanic_rating()
returns trigger as $$
begin
  update mechanic_profiles
  set
    rating = (
      select round(avg(rating)::numeric, 1)
      from reviews
      where mechanic_id = NEW.mechanic_id
    ),
    review_count = (
      select count(*)
      from reviews
      where mechanic_id = NEW.mechanic_id
    )
  where id = NEW.mechanic_id;
  return NEW;
end;
$$ language plpgsql security definer;

create trigger on_review_inserted
  after insert on reviews
  for each row execute function update_mechanic_rating();

-- Auto-expire subscriptions
create or replace function expire_subscriptions()
returns void as $$
  update subscriptions
  set status = 'expired'
  where status = 'active'
    and expires_at < now();
$$ language sql security definer;

-- ================================================================
-- INDEXES for performance
-- ================================================================
create index idx_vehicles_user_id on vehicles(user_id);
create index idx_mechanic_profiles_location on mechanic_profiles(latitude, longitude);
create index idx_bookings_user_id on bookings(user_id);
create index idx_bookings_mechanic_id on bookings(mechanic_id);
create index idx_bookings_status on bookings(status);
create index idx_scans_user_id on scans(user_id);
create index idx_subscriptions_mechanic_id on subscriptions(mechanic_id);
create index idx_notifications_user_id on notifications(user_id);
create index idx_reviews_mechanic_id on reviews(mechanic_id);

