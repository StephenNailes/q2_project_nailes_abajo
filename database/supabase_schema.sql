-- =====================================================
-- EcoSustain Database Schema
-- =====================================================

-- User Profiles Table
CREATE TABLE public.user_profiles (
  id text NOT NULL,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  profile_image_url text,
  total_disposed integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id)
);

-- Submissions Table
CREATE TABLE public.submissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  item_type text NOT NULL,
  quantity integer NOT NULL,
  drop_off_location text NOT NULL,
  photo_urls text[],
  status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  CONSTRAINT submissions_pkey PRIMARY KEY (id),
  CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE
);

-- Disposal History Table
CREATE TABLE public.disposal_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  submission_id uuid,
  item_type text NOT NULL,
  quantity integer NOT NULL,
  earned_points integer DEFAULT 0,
  disposed_date timestamp with time zone DEFAULT now(),
  CONSTRAINT disposal_history_pkey PRIMARY KEY (id),
  CONSTRAINT disposal_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  CONSTRAINT disposal_history_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE SET NULL
);

-- =====================================================
-- LEARNING CONTENT TABLES
-- =====================================================

-- Videos Table (YouTube Integration)
CREATE TABLE public.videos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  youtube_video_id text NOT NULL,
  thumbnail_url text,
  category text NOT NULL CHECK (category IN ('smartphone', 'laptop', 'tablet', 'charger', 'battery', 'cable', 'general')),
  duration integer NOT NULL, -- Duration in seconds
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
CREATE TABLE public.articles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  content text NOT NULL, -- Markdown or HTML content
  hero_image_url text,
  category text NOT NULL CHECK (category IN ('smartphone', 'laptop', 'tablet', 'charger', 'battery', 'cable', 'general')),
  author text NOT NULL,
  published_date timestamp with time zone DEFAULT now(),
  updated_date timestamp with time zone,
  views integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  tags text[],
  reading_time_minutes integer, -- Estimated reading time
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT articles_pkey PRIMARY KEY (id)
);

-- Admin Users Table (for content management access)
CREATE TABLE public.admin_users (
  id text NOT NULL,
  user_id text NOT NULL UNIQUE,
  role text NOT NULL CHECK (role IN ('super_admin', 'content_editor', 'moderator')),
  permissions text[],
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_users_pkey PRIMARY KEY (id),
  CONSTRAINT admin_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Disposal History Indexes
CREATE INDEX idx_disposal_history_user_id ON public.disposal_history(user_id);
CREATE INDEX idx_disposal_history_disposed_date ON public.disposal_history(disposed_date DESC);

-- Submissions Indexes
CREATE INDEX idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX idx_submissions_status ON public.submissions(status);
CREATE INDEX idx_submissions_created_at ON public.submissions(created_at DESC);

-- Videos Indexes
CREATE INDEX idx_videos_category ON public.videos(category);
CREATE INDEX idx_videos_published_date ON public.videos(published_date DESC);
CREATE INDEX idx_videos_is_featured ON public.videos(is_featured) WHERE is_featured = true;
CREATE INDEX idx_videos_tags ON public.videos USING gin(tags);

-- Articles Indexes
CREATE INDEX idx_articles_category ON public.articles(category);
CREATE INDEX idx_articles_published_date ON public.articles(published_date DESC);
CREATE INDEX idx_articles_is_featured ON public.articles(is_featured) WHERE is_featured = true;
CREATE INDEX idx_articles_tags ON public.articles USING gin(tags);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Public read access for videos and articles
CREATE POLICY "Videos are viewable by everyone" ON public.videos
  FOR SELECT USING (true);

CREATE POLICY "Articles are viewable by everyone" ON public.articles
  FOR SELECT USING (true);

-- Only admins can insert/update/delete content
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

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to auto-increment video views
CREATE OR REPLACE FUNCTION increment_video_views()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.videos 
  SET views = views + 1 
  WHERE id = NEW.video_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-increment article views
CREATE OR REPLACE FUNCTION increment_article_views()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.articles 
  SET views = views + 1 
  WHERE id = NEW.article_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate reading time based on word count
CREATE OR REPLACE FUNCTION calculate_reading_time()
RETURNS TRIGGER AS $$
DECLARE
  word_count integer;
  words_per_minute integer := 200;
BEGIN
  -- Count words in content (rough estimate)
  word_count := array_length(regexp_split_to_array(NEW.content, '\s+'), 1);
  NEW.reading_time_minutes := GREATEST(1, ROUND(word_count::numeric / words_per_minute));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate reading time for articles
CREATE TRIGGER calculate_article_reading_time
  BEFORE INSERT OR UPDATE ON public.articles
  FOR EACH ROW
  EXECUTE FUNCTION calculate_reading_time();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_videos_updated_at
  BEFORE UPDATE ON public.videos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_articles_updated_at
  BEFORE UPDATE ON public.articles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();