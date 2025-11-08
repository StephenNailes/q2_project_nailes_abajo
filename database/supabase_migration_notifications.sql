-- =====================================================
-- NOTIFICATIONS TABLE MIGRATION
-- =====================================================
-- This migration creates the notifications table for
-- in-app notifications system
-- =====================================================

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'post_approved', 'system')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    actor_id TEXT,
    actor_name TEXT,
    actor_profile_image TEXT,
    related_post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE,
    related_comment_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can delete their own notifications" ON public.notifications;
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

-- RLS Policies
-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications"
    ON public.notifications
    FOR SELECT
    USING (user_id = auth.uid()::text);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications"
    ON public.notifications
    FOR UPDATE
    USING (user_id = auth.uid()::text);

-- Users can delete their own notifications
CREATE POLICY "Users can delete their own notifications"
    ON public.notifications
    FOR DELETE
    USING (user_id = auth.uid()::text);

-- Anyone authenticated can create notifications (for system/user-generated notifications)
CREATE POLICY "System can create notifications"
    ON public.notifications
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Add comment to table
COMMENT ON TABLE public.notifications IS 'Stores in-app notifications for users';
COMMENT ON COLUMN public.notifications.type IS 'Type of notification: like, comment, follow, post_approved, system';
COMMENT ON COLUMN public.notifications.actor_id IS 'User ID of the person who triggered the notification';
COMMENT ON COLUMN public.notifications.related_post_id IS 'ID of related community post (for like/comment notifications)';
