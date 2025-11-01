-- =====================================================
-- Migration: Add Learning Content Tables
-- Date: November 1, 2025
-- Description: Adds videos and articles tables for learning hub
-- =====================================================

BEGIN;

-- =====================================================
-- CREATE TABLES
-- =====================================================

-- Videos Table (YouTube Integration)
CREATE TABLE IF NOT EXISTS public.videos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  youtube_video_id text NOT NULL,
  thumbnail_url text,
  category text NOT NULL CHECK (category IN ('smartphone', 'laptop', 'tablet', 'charger', 'battery', 'cable', 'general')),
  duration integer NOT NULL,
  author text NOT NULL,
  published_date timestamp with time zone DEFAULT now(),
  views integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  tags text[],
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT videos_pkey PRIMARY KEY (id)
);

-- Articles Table
CREATE TABLE IF NOT EXISTS public.articles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  content text NOT NULL,
  hero_image_url text,
  category text NOT NULL CHECK (category IN ('smartphone', 'laptop', 'tablet', 'charger', 'battery', 'cable', 'general')),
  author text NOT NULL,
  published_date timestamp with time zone DEFAULT now(),
  updated_date timestamp with time zone,
  views integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  tags text[],
  reading_time_minutes integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT articles_pkey PRIMARY KEY (id)
);

-- Admin Users Table
CREATE TABLE IF NOT EXISTS public.admin_users (
  id text NOT NULL,
  user_id text NOT NULL UNIQUE,
  role text NOT NULL CHECK (role IN ('super_admin', 'content_editor', 'moderator')),
  permissions text[],
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_users_pkey PRIMARY KEY (id),
  CONSTRAINT admin_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE
);

-- =====================================================
-- CREATE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_videos_category ON public.videos(category);
CREATE INDEX IF NOT EXISTS idx_videos_published_date ON public.videos(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_videos_is_featured ON public.videos(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_videos_tags ON public.videos USING gin(tags);

CREATE INDEX IF NOT EXISTS idx_articles_category ON public.articles(category);
CREATE INDEX IF NOT EXISTS idx_articles_published_date ON public.articles(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_articles_is_featured ON public.articles(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_articles_tags ON public.articles USING gin(tags);

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CREATE RLS POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Videos are viewable by everyone" ON public.videos;
DROP POLICY IF EXISTS "Articles are viewable by everyone" ON public.articles;
DROP POLICY IF EXISTS "Only admins can manage videos" ON public.videos;
DROP POLICY IF EXISTS "Only admins can manage articles" ON public.articles;
DROP POLICY IF EXISTS "Admins can view admin table" ON public.admin_users;

-- Public read access
CREATE POLICY "Videos are viewable by everyone" ON public.videos
  FOR SELECT USING (true);

CREATE POLICY "Articles are viewable by everyone" ON public.articles
  FOR SELECT USING (true);

-- Admin write access
CREATE POLICY "Only admins can manage videos" ON public.videos
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid()::text
    )
  );

CREATE POLICY "Only admins can manage articles" ON public.articles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid()::text
    )
  );

CREATE POLICY "Admins can view admin table" ON public.admin_users
  FOR SELECT USING (
    user_id = auth.uid()::text
  );

-- =====================================================
-- CREATE FUNCTIONS
-- =====================================================

-- Function to calculate reading time
CREATE OR REPLACE FUNCTION calculate_reading_time()
RETURNS TRIGGER AS $$
DECLARE
  word_count integer;
  words_per_minute integer := 200;
BEGIN
  word_count := array_length(regexp_split_to_array(NEW.content, '\s+'), 1);
  NEW.reading_time_minutes := GREATEST(1, ROUND(word_count::numeric / words_per_minute));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CREATE TRIGGERS
-- =====================================================

DROP TRIGGER IF EXISTS calculate_article_reading_time ON public.articles;
CREATE TRIGGER calculate_article_reading_time
  BEFORE INSERT OR UPDATE ON public.articles
  FOR EACH ROW
  EXECUTE FUNCTION calculate_reading_time();

DROP TRIGGER IF EXISTS update_videos_updated_at ON public.videos;
CREATE TRIGGER update_videos_updated_at
  BEFORE UPDATE ON public.videos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_articles_updated_at ON public.articles;
CREATE TRIGGER update_articles_updated_at
  BEFORE UPDATE ON public.articles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA (Migrating from static data)
-- =====================================================

-- Insert Videos
INSERT INTO public.videos (title, description, youtube_video_id, thumbnail_url, category, duration, author, tags, is_featured, views)
VALUES
  (
    'How to Safely Dispose of Old Smartphones',
    'Learn the proper steps to prepare and dispose of your old smartphones, including data wiping, battery removal, and finding certified e-waste centers.',
    'dQw4w9WgXcQ',
    'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    'smartphone',
    720,
    'Green Tech Team',
    ARRAY['smartphone', 'data-security', 'e-waste'],
    true,
    1547
  ),
  (
    'Laptop Refurbishing: Step-by-Step Tutorial',
    'Transform your old laptop into a functional device. This comprehensive guide covers cleaning, upgrading components, and installing lightweight operating systems.',
    'oHg5SJYRHA0',
    'https://img.youtube.com/vi/oHg5SJYRHA0/maxresdefault.jpg',
    'laptop',
    1800,
    'Tech Reuse Initiative',
    ARRAY['laptop', 'refurbish', 'upgrade', 'reuse'],
    true,
    2341
  ),
  (
    'Battery Disposal: What You Need to Know',
    'Understand the different types of batteries, their environmental impact, and the safest disposal methods. Includes information on lithium-ion, NiMH, and alkaline batteries.',
    'yPYZpwSpKmA',
    'https://img.youtube.com/vi/yPYZpwSpKmA/maxresdefault.jpg',
    'battery',
    540,
    'Eco Warriors',
    ARRAY['battery', 'safety', 'environment'],
    false,
    892
  ),
  (
    'Cable and Charger Recycling Made Easy',
    'Stop throwing away old cables and chargers! Learn about specialized recycling programs, donation options, and creative reuse ideas for electronic accessories.',
    '9bZkp7q19f0',
    'https://img.youtube.com/vi/9bZkp7q19f0/maxresdefault.jpg',
    'cable',
    420,
    'Sustainable Living',
    ARRAY['cable', 'charger', 'recycling'],
    false,
    634
  ),
  (
    'E-Waste Impact: The Hidden Environmental Cost',
    'Discover the shocking truth about e-waste pollution and why proper disposal matters. This eye-opening documentary explores toxic materials, global impact, and solutions.',
    'jNQXAC9IVRw',
    'https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg',
    'general',
    900,
    'Environmental Docs',
    ARRAY['environment', 'awareness', 'pollution'],
    true,
    3156
  )
ON CONFLICT DO NOTHING;

-- Insert Articles (using markdown content)
INSERT INTO public.articles (title, description, content, hero_image_url, category, author, tags, is_featured, views)
VALUES
  (
    'The Complete Guide to E-Waste Disposal',
    'Everything you need to know about responsibly disposing of electronic waste in 2024.',
    E'# The Complete Guide to E-Waste Disposal\n\nElectronic waste, or e-waste, represents one of the fastest-growing waste streams globally. This comprehensive guide will help you understand how to properly dispose of your electronic devices.\n\n## Why E-Waste Disposal Matters\n\nImproper disposal of electronics can lead to:\n\n- **Environmental Contamination**: Toxic materials like lead, mercury, and cadmium can leach into soil and groundwater\n- **Health Hazards**: Exposure to hazardous substances affects communities near disposal sites\n- **Resource Waste**: Electronics contain valuable materials like gold, silver, and rare earth elements\n\n## Types of E-Waste\n\n### 1. Large Appliances\n- Refrigerators\n- Washing machines\n- Air conditioners\n\n### 2. Small Electronics\n- Smartphones\n- Tablets\n- Cameras\n\n### 3. IT Equipment\n- Laptops\n- Desktops\n- Printers\n\n## Disposal Methods\n\n### Certified E-Waste Centers\nLook for facilities certified by:\n- ✓ R2 (Responsible Recycling)\n- ✓ e-Stewards\n- ✓ ISO 14001\n\n### Manufacturer Take-Back Programs\nMany brands offer free recycling:\n- Apple Trade-In\n- Dell Reconnect\n- Best Buy Recycling\n\n### Local Drop-Off Events\nCommunity e-waste collection drives provide convenient disposal options.\n\n## Before You Dispose\n\n**Critical Steps:**\n1. Back up all data\n2. Perform factory reset\n3. Remove SIM cards and memory cards\n4. Sign out of all accounts\n5. Remove batteries if possible\n\n## What Happens After Disposal?\n\n1. **Collection**: Items gathered at certified facilities\n2. **Sorting**: Manual and automated separation by material type\n3. **Dismantling**: Safe removal of hazardous components\n4. **Processing**: Recovery of valuable materials\n5. **Recycling**: Materials returned to manufacturing supply chains\n\n## Regulations by Region\n\n### United States\n- EPA regulates e-waste under RCRA\n- State-specific programs vary\n- Some states ban landfill disposal\n\n### European Union\n- WEEE Directive mandates proper disposal\n- Free take-back at retailers\n- Producer-funded programs\n- Strict export controls\n\n## The Future of E-Waste\n\nEmerging solutions include:\n- **Urban Mining**: Extracting materials from old electronics\n- **Circular Economy**: Designing for disassembly and reuse\n- **Extended Producer Responsibility**: Manufacturers responsible for end-of-life\n\n## Take Action Today\n\nStart your e-waste disposal journey:\n1. Inventory your unused electronics\n2. Find your nearest certified center\n3. Prepare devices for disposal\n4. Schedule drop-off or pickup\n5. Share knowledge with others\n\n*Together, we can reduce e-waste and protect our planet.*',
    'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b',
    'general',
    'EcoSustain Team',
    ARRAY['e-waste', 'disposal', 'environment', 'guide'],
    true,
    2847
  ),
  (
    'How to Prepare Your Smartphone for Disposal',
    'A step-by-step checklist to ensure your data is safe before disposing of your phone.',
    E'# How to Prepare Your Smartphone for Disposal\n\nBefore saying goodbye to your old smartphone, follow these essential steps to protect your privacy and prepare it for its next life.\n\n## Data Security Checklist\n\n### Step 1: Backup Everything\n- ✓ Photos and videos\n- ✓ Contacts\n- ✓ Messages\n- ✓ App data\n- ✓ Documents\n\n**Tools to use:**\n- iCloud (iPhone)\n- Google Drive (Android)\n- Local computer backup\n\n### Step 2: Sign Out of Accounts\nRemove these before factory reset:\n- Google Account\n- Apple ID\n- Samsung Account\n- Banking apps\n- Social media apps\n- Email accounts\n\n### Step 3: Remove External Storage\n- SIM card\n- SD card (if applicable)\n- Phone case and accessories\n\n### Step 4: Factory Reset\n\n**For iPhone:**\n1. Settings → General → Transfer or Reset iPhone\n2. Select "Erase All Content and Settings"\n3. Enter passcode\n4. Confirm erasure\n\n**For Android:**\n1. Settings → System → Reset options\n2. Select "Erase all data (factory reset)"\n3. Enter PIN/password\n4. Confirm reset\n\n### Step 5: Remove Accounts\nAfter reset, verify:\n- Device is not linked to Find My iPhone/Android\n- iCloud/Google account removed\n- Device activation lock disabled\n\n## Physical Preparation\n\n### Clean the Device\n- Wipe screen and body\n- Remove any stickers\n- Check for damage\n\n### Battery Check\n- Ensure battery is not swollen\n- If damaged, handle separately\n- Inform disposal facility of battery issues\n\n## Where to Dispose\n\n### Recommended Options\n1. **Manufacturer Programs**\n   - Apple Trade-In\n   - Samsung Galaxy Recycle\n   - Google Store Trade-In\n\n2. **Retailer Take-Back**\n   - Best Buy\n   - Target\n   - Staples\n\n3. **Certified E-Waste Centers**\n   - Find via EPA website\n   - Check local government resources\n\n4. **Donation (if working)**\n   - Shelters\n   - Schools\n   - Nonprofit organizations\n\n## Common Mistakes to Avoid\n\n❌ **Don''t:**\n- Throw in regular trash\n- Forget to remove SIM card\n- Skip factory reset\n- Donate without wiping data\n- Break the device (releases toxins)\n\n✅ **Do:**\n- Use certified facilities\n- Keep proof of disposal\n- Remove all accessories\n- Check for trade-in value\n\n## Environmental Impact\n\nOne smartphone contains:\n- 🌟 Gold: 0.034g\n- 🌟 Silver: 0.34g\n- 🌟 Copper: 15g\n- ⚠️ Toxic materials if improperly disposed\n\n*Your responsible disposal helps recover these materials and prevents environmental harm.*',
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
    'smartphone',
    'Data Security Team',
    ARRAY['smartphone', 'data-privacy', 'disposal', 'guide'],
    true,
    1923
  );

-- Verify insertion
DO $$
BEGIN
  RAISE NOTICE '✅ Migration completed successfully!';
  RAISE NOTICE 'Videos added: %', (SELECT COUNT(*) FROM public.videos);
  RAISE NOTICE 'Articles added: %', (SELECT COUNT(*) FROM public.articles);
END $$;

COMMIT;
