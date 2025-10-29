# 🐘 Supabase Setup - Step by Step

## ✅ Step 1: Create Supabase Project (DONE via browser)

After creating your project in https://supabase.com/dashboard, you should have:
- Project created (name: ecosustain or similar)
- Database password saved
- Project is provisioning (takes ~2 minutes)

---

## 📋 Step 2: Get Your Credentials

Once your project is ready:

1. Click **⚙️ Project Settings** (gear icon in left sidebar)
2. Click **API** in the settings menu
3. Find and copy these two values:

### You need:
```
Project URL: https://xxxxxxxxxxxxx.supabase.co
Anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Keep these safe! You'll paste them in the next step.**

---

## 🗄️ Step 3: Create Database Tables

1. In Supabase Dashboard, go to **SQL Editor** (in left sidebar)
2. Click **New query**
3. Open the file: `supabase_schema.sql` (in your project root)
4. **Copy ALL the SQL** from that file
5. **Paste it** into the SQL Editor in Supabase
6. Click **Run** (bottom right corner)

**Expected result**: You should see "Success. No rows returned"

This creates:
- ✅ `user_profiles` table
- ✅ `submissions` table
- ✅ `recycling_history` table
- ✅ `eco_tips` table (with 5 sample tips)
- ✅ Security policies (Row Level Security)
- ✅ Indexes for performance

---

## 🔧 Step 4: Update Your Flutter App Config

**Once you have your credentials**, tell me:

```
My Supabase URL: [paste here]
My Supabase Anon Key: [paste here]
```

And I'll update your `lib/config/env_config.dart` file automatically!

---

## ✅ Step 5: Enable Authentication (Optional but Recommended)

In Supabase Dashboard:

1. Go to **Authentication** → **Providers**
2. **Email** is enabled by default ✅
3. For Google Sign-In:
   - Click **Google**
   - Toggle **Enable**
   - Add authorized redirect URLs (I'll help with this later)

---

## 🧪 Step 6: Verify Setup

After I update your config, we'll test it:

```powershell
flutter run
```

Look for:
```
✅ Supabase initialized successfully
```

---

## 📊 What You'll Get

Once connected:
- ✅ PostgreSQL database (500MB free)
- ✅ Real-time data synchronization
- ✅ User authentication
- ✅ Row-level security
- ✅ Automatic API generation
- ✅ 5 sample eco tips already loaded

---

## 🎯 Current Status

- [x] Supabase project created
- [ ] Credentials obtained (waiting for you)
- [ ] Database schema created (SQL ready)
- [ ] App config updated (waiting for credentials)
- [ ] Test connection

---

## 💡 Next Steps

**Tell me when you have:**
1. ✅ Your Supabase URL
2. ✅ Your Supabase Anon Key

Then I'll:
1. Update `env_config.dart` with your credentials
2. Enable Supabase in your app
3. Test the connection
4. Show you how to view data in Supabase Dashboard

**Ready? Paste your credentials when you have them!** 😊
