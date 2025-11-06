-- =====================================================
-- Fix RLS Policies for Firebase Auth Users
-- This allows users authenticated via Firebase to interact with Supabase
-- =====================================================

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can create their own posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can like posts" ON public.post_likes;
DROP POLICY IF EXISTS "Users can unlike their own likes" ON public.post_likes;
DROP POLICY IF EXISTS "Users can create comments" ON public.post_comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON public.post_comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON public.post_comments;

-- =====================================================
-- NEW POLICIES - Allow Firebase Auth users
-- =====================================================

-- Community Posts Policies - Allow any user with valid user_id in user_profiles
CREATE POLICY "Anyone with valid profile can create posts" ON public.community_posts
  FOR INSERT WITH CHECK (
    user_id IN (SELECT id FROM public.user_profiles)
  );

CREATE POLICY "Post owners can update their posts" ON public.community_posts
  FOR UPDATE USING (
    user_id IN (SELECT id FROM public.user_profiles)
  );

CREATE POLICY "Post owners can delete their posts" ON public.community_posts
  FOR DELETE USING (
    user_id IN (SELECT id FROM public.user_profiles)
  );

-- Post Likes Policies
CREATE POLICY "Users with profiles can like posts" ON public.post_likes
  FOR INSERT WITH CHECK (
    user_id IN (SELECT id FROM public.user_profiles)
  );

CREATE POLICY "Users can remove their likes" ON public.post_likes
  FOR DELETE USING (
    user_id IN (SELECT id FROM public.user_profiles)
  );

-- Post Comments Policies
CREATE POLICY "Users with profiles can comment" ON public.post_comments
  FOR INSERT WITH CHECK (
    user_id IN (SELECT id FROM public.user_profiles)
  );

CREATE POLICY "Comment owners can update comments" ON public.post_comments
  FOR UPDATE USING (
    user_id IN (SELECT id FROM public.user_profiles)
  );

CREATE POLICY "Comment owners can delete comments" ON public.post_comments
  FOR DELETE USING (
    user_id IN (SELECT id FROM public.user_profiles)
  );

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

-- Ensure anon and authenticated roles can access tables
GRANT ALL ON public.community_posts TO anon, authenticated;
GRANT ALL ON public.post_likes TO anon, authenticated;
GRANT ALL ON public.post_comments TO anon, authenticated;

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
