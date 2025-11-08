-- Add tracking_status column to community_posts table
-- This allows users to track their submission status (pending, in_progress, completed)

-- Add tracking_status column with default value 'pending'
ALTER TABLE community_posts 
ADD COLUMN IF NOT EXISTS tracking_status TEXT DEFAULT 'pending' CHECK (tracking_status IN ('pending', 'in_progress', 'completed'));

-- Create index for faster queries filtering by tracking_status
CREATE INDEX IF NOT EXISTS idx_community_posts_tracking_status 
ON community_posts(tracking_status);

-- Create index for user_id + tracking_status combination (common query pattern)
CREATE INDEX IF NOT EXISTS idx_community_posts_user_tracking 
ON community_posts(user_id, tracking_status);

-- Add comment to explain the column
COMMENT ON COLUMN community_posts.tracking_status IS 'Tracking status: pending (awaiting pickup), in_progress (being processed), completed (disposed/repurposed)';

-- Set default tracking_status for existing posts
UPDATE community_posts 
SET tracking_status = 'pending' 
WHERE tracking_status IS NULL;
