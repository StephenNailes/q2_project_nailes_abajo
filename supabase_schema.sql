-- User Profiles Table
CREATE TABLE user_profiles (
    id text PRIMARY KEY,
    name text NOT NULL,
    email text UNIQUE NOT NULL,
    profile_image_url text,
    total_recycled integer DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Submissions Table
CREATE TABLE submissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id text NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    item_type text NOT NULL,
    quantity integer NOT NULL,
    drop_off_location text NOT NULL,
    photo_urls text[],
    status text DEFAULT 'pending',
    created_at timestamptz DEFAULT now(),
    completed_at timestamptz
);

-- Recycling History Table
CREATE TABLE recycling_history (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id text NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    submission_id uuid REFERENCES submissions(id) ON DELETE SET NULL,
    item_type text NOT NULL,
    quantity integer NOT NULL,
    earned_points integer DEFAULT 0,
    recycled_date timestamptz DEFAULT now()
);

-- Eco Tips Table
CREATE TABLE eco_tips (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    content text NOT NULL,
    category text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE recycling_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE eco_tips ENABLE ROW LEVEL SECURITY;

-- Permissive policies (since Firebase Auth controls access)
CREATE POLICY "Allow all operations" ON user_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON submissions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON recycling_history FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON eco_tips FOR ALL USING (true) WITH CHECK (true);

-- Create indexes for performance
CREATE INDEX idx_submissions_user_id ON submissions(user_id);
CREATE INDEX idx_submissions_status ON submissions(status);
CREATE INDEX idx_recycling_history_user_id ON recycling_history(user_id);
CREATE INDEX idx_eco_tips_category ON eco_tips(category);