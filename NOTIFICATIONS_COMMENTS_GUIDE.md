# Notifications & Comments Implementation Guide

## Overview
This document describes the newly implemented notifications and comments system with modern UI design.

## Features Implemented

### 1. ✅ Modern Toast Notifications
**Location**: `lib/utils/toast_utils.dart`

A beautiful, animated toast notification system with:
- **Success toasts** (green) - For successful operations
- **Error toasts** (red) - For errors
- **Info toasts** (blue) - For informational messages
- **Warning toasts** (orange) - For warnings

**Usage**:
```dart
import '../utils/toast_utils.dart';

// Success
ToastUtils.showSuccess(context, message: 'Post created successfully! 🎉');

// Error
ToastUtils.showError(context, message: 'Failed to create post');

// Info
ToastUtils.showInfo(context, message: 'Please check your connection');

// Warning
ToastUtils.showWarning(context, message: 'This action cannot be undone');
```

**Features**:
- Smooth slide-down animation from top
- Auto-dismiss after duration
- Modern glassmorphism design
- Icon support with background glow
- Customizable duration

---

### 2. ✅ Functional Likes System
**Location**: `lib/screen/community_feed_screen.dart`

The like system now:
- ✅ Updates Supabase in real-time
- ✅ Shows optimistic UI updates (instant feedback)
- ✅ Creates notifications for post owners
- ✅ Tracks which posts current user has liked
- ✅ Updates like count dynamically

**How it works**:
1. User taps like button
2. UI updates immediately (optimistic)
3. Backend call to Supabase
4. Notification created for post owner (if different user)
5. Post owner receives notification: "X liked your Y disposal post"

---

### 3. ✅ Functional Comments System
**Location**: `lib/screen/comments_screen.dart`

A complete comments feature with:
- **Modern chat-like UI** with rounded bubbles
- **Real-time updates** via pull-to-refresh
- **User avatars** and timestamps
- **Keyboard-aware input** that stays at bottom
- **Send button** with loading state
- **Empty state** with beautiful illustration
- **Notifications** for post owners when commented

**Navigation**:
```dart
context.push('/community/post/${postId}/comments?ownerId=${ownerId}');
```

**Features**:
- Smooth animations
- Auto-scroll to latest comment
- User profile integration
- Timestamp with "time ago" format (e.g., "2h ago", "3d ago")

---

### 4. ✅ Modern Notifications Screen
**Location**: `lib/screen/notifications_screen.dart`

A complete notification system with:

**Features**:
- **Real data from Supabase** (no more hardcoded)
- **Beautiful card design** with shadows and animations
- **Unread indicator** (green dot + border)
- **Mark all as read** functionality
- **Swipe to delete** (Material Design dismissible)
- **Empty state** with illustration
- **Pull to refresh**
- **Error handling** with retry button

**Notification Types**:
1. **Like** (❤️ Red) - "X liked your post"
2. **Comment** (💬 Blue) - "X commented: 'Nice!'"
3. **Follow** (👤 Purple) - "X started following you"
4. **Post Approved** (✅ Green) - "Your post has been approved"
5. **System** (🔔 Orange) - System announcements

**Design**:
- Color-coded by type
- Actor avatar (if available)
- Time ago format (2h ago, 3d ago)
- Unread count in app bar
- Smooth transitions

---

## Database Schema

### Notifications Table
```sql
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL, -- 'like', 'comment', 'follow', 'post_approved', 'system'
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    actor_id TEXT,
    actor_name TEXT,
    actor_profile_image TEXT,
    related_post_id UUID,
    related_comment_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes**:
- `user_id` - Fast user queries
- `created_at DESC` - Sorted by newest first
- `is_read` - Quick unread filtering
- Composite index on `(user_id, is_read)` for unread count

**RLS Policies**:
- Users can view their own notifications
- Users can update their own notifications (mark as read)
- Users can delete their own notifications
- Authenticated users can create notifications

---

## Migration Steps

### Step 1: Run SQL Migration
```bash
# Run this in Supabase SQL Editor
supabase_migration_notifications.sql
```

### Step 2: Test Notifications
1. Like a post (should create notification for post owner)
2. Comment on a post (should create notification for post owner)
3. Check notifications screen
4. Mark as read
5. Swipe to delete

### Step 3: Test Comments
1. Open any community post
2. Tap "Comment" button
3. Write a comment
4. Submit
5. See it appear instantly
6. Pull to refresh

### Step 4: Test Toast Notifications
1. Create a new post
2. See success toast appear from top
3. Try with invalid data (see error toast)

---

## API Methods Added

### Supabase Service (`lib/services/supabase_service.dart`)

```dart
// Notifications
Future<void> createNotification({...})
Future<List<Map<String, dynamic>>> getUserNotifications(userId, {limit})
Future<int> getUnreadNotificationCount(userId)
Future<void> markNotificationAsRead(notificationId)
Future<void> markAllNotificationsAsRead(userId)
Future<void> deleteNotification(notificationId)
Stream<List<Map<String, dynamic>>> streamUserNotifications(userId)

// Comments (already existed, now functional)
Future<void> addComment({postId, userId, comment})
Future<List<Map<String, dynamic>>> getPostComments(postId)
```

---

## Models Created

### 1. NotificationModel
**Location**: `lib/models/notification_model.dart`

```dart
NotificationModel(
  id: 'uuid',
  userId: 'user-123',
  type: 'like',
  title: 'New like',
  message: 'John liked your post',
  actorId: 'john-123',
  actorName: 'John Doe',
  actorProfileImage: 'url',
  relatedPostId: 'post-123',
  isRead: false,
  createdAt: DateTime.now(),
)
```

**Methods**:
- `fromJson()` - Parse from Supabase
- `toSupabaseJson()` - Convert to Supabase format
- `timeAgo` - "2h ago", "3d ago" format
- `copyWith()` - Immutable updates

### 2. CommentModel
**Location**: `lib/models/comment_model.dart`

```dart
CommentModel(
  id: 'uuid',
  postId: 'post-123',
  userId: 'user-123',
  userName: 'John Doe',
  userProfileImage: 'url',
  comment: 'Great work!',
  createdAt: DateTime.now(),
)
```

---

## UI/UX Improvements

### Toast Notifications
- ✅ Slide-down animation from top
- ✅ Auto-dismiss after 3-4 seconds
- ✅ Icon with colored background
- ✅ Blur effect and shadow
- ✅ No more ugly SnackBars

### Notifications Screen
- ✅ Gradient background (matches app theme)
- ✅ White cards with soft shadows
- ✅ Unread indicator (green dot + border)
- ✅ Color-coded by notification type
- ✅ Swipe-to-delete gesture
- ✅ Empty state illustration
- ✅ Pull-to-refresh

### Comments Screen
- ✅ Chat-like interface
- ✅ Rounded input field with send button
- ✅ User avatars
- ✅ Time ago timestamps
- ✅ Empty state with call-to-action
- ✅ Loading states
- ✅ Keyboard-aware scrolling

---

## Navigation Routes Added

```dart
// Comments route
GoRoute(
  path: '/community/post/:postId/comments',
  builder: (context, state) {
    final postId = state.pathParameters['postId']!;
    final postOwnerUserId = state.uri.queryParameters['ownerId'] ?? '';
    return CommentsScreen(
      postId: postId,
      postOwnerUserId: postOwnerUserId,
    );
  },
)
```

---

## Testing Checklist

### Likes
- [ ] Like a post (should update count)
- [ ] Unlike a post (should decrease count)
- [ ] Post owner receives notification (if different user)
- [ ] Notification links to correct post

### Comments
- [ ] Open comments screen
- [ ] Add a comment
- [ ] See comment appear instantly
- [ ] Post owner receives notification
- [ ] Empty state shows when no comments
- [ ] Pull to refresh works

### Notifications
- [ ] Receive notification on like
- [ ] Receive notification on comment
- [ ] Unread count shows in app bar
- [ ] Mark single notification as read
- [ ] Mark all as read
- [ ] Swipe to delete
- [ ] Empty state shows when no notifications

### Toast Notifications
- [ ] Success toast on post creation
- [ ] Error toast on API failure
- [ ] Toast auto-dismisses
- [ ] Toast slides from top

---

## Future Enhancements

### Notifications
- [ ] Push notifications (FCM integration)
- [ ] Notification preferences
- [ ] Group similar notifications
- [ ] Real-time notification stream (WebSocket)

### Comments
- [ ] Reply to comments (nested)
- [ ] Like comments
- [ ] Delete own comments
- [ ] Edit comments
- [ ] @mentions

### Toast
- [ ] Queue multiple toasts
- [ ] Persistent toasts (manual dismiss)
- [ ] Action buttons in toasts

---

## Troubleshooting

### Notifications not appearing?
1. Check Supabase RLS policies are enabled
2. Verify user is authenticated
3. Check network connection
4. Look for errors in debug console

### Comments not loading?
1. Verify `post_comments` table exists
2. Check RLS policies allow SELECT
3. Ensure user profile exists
4. Check Firebase Auth is connected

### Toast not showing?
1. Verify `context` is valid
2. Check `ToastUtils` is imported
3. Ensure widget is mounted
4. Look for overlay errors

---

## Performance Optimizations

1. **Optimistic UI Updates** - Instant feedback on likes/comments
2. **Lazy Loading** - Only load 50-100 notifications at a time
3. **Image Caching** - User avatars cached locally
4. **Debouncing** - Prevent duplicate API calls
5. **Index Optimization** - Fast queries on notifications table

---

## Accessibility

- ✅ Semantic labels on buttons
- ✅ High contrast colors
- ✅ Touch targets 48x48 minimum
- ✅ Keyboard navigation support
- ✅ Screen reader friendly

---

## Credits

Designed and implemented following Material Design 3 guidelines and Flutter best practices.

**Package Dependencies**:
- `supabase_flutter` - Backend integration
- `firebase_auth` - Authentication
- `go_router` - Navigation

---

## Support

For issues or questions, refer to:
- `BACKEND_INTEGRATION_GUIDE.md` - Supabase setup
- `ARCHITECTURE.md` - App structure
- Supabase logs - Check for RLS policy issues
