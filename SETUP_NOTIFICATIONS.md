# 🚀 Quick Setup: Notifications System

## Step 1: Run SQL Migration

1. Open your **Supabase Dashboard**: https://supabase.com/dashboard
2. Select your project: **TechSustain**
3. Navigate to: **SQL Editor** (left sidebar)
4. Click: **New Query**
5. Copy and paste the contents of: `supabase_migration_notifications.sql`
6. Click: **Run** (or press `Ctrl+Enter`)

✅ You should see: "Success. No rows returned"

---

## Step 2: Verify Table Creation

In the SQL Editor, run this query:
```sql
SELECT * FROM public.notifications LIMIT 5;
```

✅ Expected result: Empty table (0 rows) - this is correct!

---

## Step 3: Test Notifications

### A. Create Test Notification (Optional)
You can manually create a test notification to verify the system:

```sql
INSERT INTO public.notifications (
    user_id,
    type,
    title,
    message,
    is_read
) VALUES (
    'YOUR_FIREBASE_USER_ID',  -- Replace with your Firebase Auth UID
    'system',
    'Welcome to TechSustain!',
    'Thank you for joining our community. Start sharing your e-waste disposal stories!',
    false
);
```

To get your Firebase User ID:
1. Open app
2. Go to Profile screen
3. Your user ID is displayed (or check Firebase Auth console)

### B. Test via App
1. Open the app
2. Like someone's post → Post owner gets notification
3. Comment on someone's post → Post owner gets notification
4. Open Notifications screen → See your notifications

---

## Step 4: Verify RLS Policies

Run this query to check if Row Level Security is enabled:

```sql
SELECT tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'notifications';
```

✅ You should see 4 policies:
1. "Users can view their own notifications" (SELECT)
2. "Users can update their own notifications" (UPDATE)
3. "Users can delete their own notifications" (DELETE)
4. "System can create notifications" (INSERT)

---

## Step 5: Test in App

### Test Likes Notification
1. **User A**: Create a post
2. **User B**: Like User A's post
3. **User A**: Check notifications screen
4. ✅ Should see: "User B liked your [item] disposal post"

### Test Comments Notification
1. **User A**: Create a post
2. **User B**: Comment on User A's post
3. **User A**: Check notifications screen
4. ✅ Should see: "User B commented: '[comment text]'"

### Test Toast Notification
1. Create a new post
2. ✅ Should see green toast: "Post created successfully! 🎉"

---

## Troubleshooting

### Issue: Notifications not appearing in app

**Solution 1**: Check user is logged in
```dart
final user = FirebaseAuth.instance.currentUser;
print('User ID: ${user?.uid}');
```

**Solution 2**: Check Supabase connection
```sql
-- Run in Supabase SQL Editor
SELECT COUNT(*) FROM public.notifications;
```

**Solution 3**: Check RLS policies
```sql
-- Temporarily disable RLS to test (ONLY FOR DEBUGGING)
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;

-- Re-enable after testing
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
```

### Issue: "Permission denied" error

**Cause**: RLS policies blocking access

**Solution**: Verify your Firebase Auth UID matches Supabase user_id:
```sql
SELECT * FROM public.notifications 
WHERE user_id = 'YOUR_FIREBASE_UID';
```

### Issue: Notifications table doesn't exist

**Solution**: Re-run the migration SQL file

---

## Indexes Verification

Check if indexes were created:
```sql
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'notifications';
```

✅ Should see indexes:
- `notifications_pkey` (primary key)
- `idx_notifications_user_id`
- `idx_notifications_created_at`
- `idx_notifications_is_read`
- `idx_notifications_user_unread`

---

## Performance Check

Check notification count per user:
```sql
SELECT user_id, COUNT(*) as notification_count
FROM public.notifications
GROUP BY user_id
ORDER BY notification_count DESC
LIMIT 10;
```

Check unread notifications:
```sql
SELECT user_id, COUNT(*) as unread_count
FROM public.notifications
WHERE is_read = false
GROUP BY user_id
ORDER BY unread_count DESC
LIMIT 10;
```

---

## Clean Up Old Notifications (Optional)

If you want to delete notifications older than 30 days:
```sql
DELETE FROM public.notifications 
WHERE created_at < NOW() - INTERVAL '30 days';
```

---

## Monitoring

### Check latest notifications:
```sql
SELECT 
    n.type,
    n.title,
    n.message,
    n.is_read,
    n.created_at,
    n.actor_name
FROM public.notifications n
ORDER BY n.created_at DESC
LIMIT 20;
```

### Check notification stats:
```sql
SELECT 
    type,
    COUNT(*) as count,
    COUNT(CASE WHEN is_read = false THEN 1 END) as unread_count
FROM public.notifications
GROUP BY type
ORDER BY count DESC;
```

---

## Success Criteria ✅

- [x] Notifications table created
- [x] RLS policies enabled
- [x] Indexes created
- [x] App can read notifications
- [x] App can create notifications
- [x] App can mark as read
- [x] App can delete notifications
- [x] Toast notifications appear
- [x] Like creates notification
- [x] Comment creates notification

---

## Next Steps

1. ✅ Run migration SQL
2. ✅ Test in app
3. ✅ Monitor Supabase logs for errors
4. ✅ Adjust RLS policies if needed
5. ✅ Consider push notifications (FCM) in future

---

## Support

If you encounter issues:
1. Check Supabase logs (Dashboard → Logs)
2. Check Flutter console for errors
3. Verify Firebase Auth is working
4. Test with Supabase SQL Editor directly

**Everything should work immediately after running the migration!** 🎉
