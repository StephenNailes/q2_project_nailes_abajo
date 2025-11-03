# 🔒 Security Fix Guide - API Keys Exposed in Git History

## ⚠️ CRITICAL: API Keys Found in Git History

Your Firebase API key was accidentally committed to the repository in `android/app/google-services.json`.

**Exposed API Key:** `AIzaSyCtYO930CM6Ctk8SdK9l3RrDF2uz1FfqKo`  
**Commit:** `7785ba0a95610857bbc4842f3944f0b3f1872ac5`  
**File:** `android/app/google-services.json`

---

## 🚨 Immediate Actions Required

### Step 1: Rotate the Compromised API Key

**CRITICAL:** Since the API key is in git history, anyone who clones this repo can see it. You must:

1. **Go to Firebase Console** → https://console.firebase.google.com
2. Select your project: **eco-sustain-51b9b**
3. Go to **Project Settings** → **General** → **Web API Key**
4. **Regenerate/Rotate the API key** to invalidate the exposed one
5. Download a new `google-services.json` file
6. **Add application restrictions** to prevent unauthorized use

### Step 2: Add google-services.json to .gitignore

**Status:** ✅ Already done! Your `.gitignore` contains patterns to exclude this file.

However, we need to ensure it's explicitly listed:

```bash
# Add this line to .gitignore if not already there
android/app/google-services.json
```

### Step 3: Remove from Git History

You have two options:

#### Option A: Use git-filter-repo (Recommended)

```powershell
# Install git-filter-repo
pip install git-filter-repo

# Navigate to your repo
cd "c:\Users\MYPC\Documents\EcoSustain\Eco-Sustain-Flutter-App"

# Remove the file from all commits
git filter-repo --path android/app/google-services.json --invert-paths

# Force push to remote (WARNING: This rewrites history!)
git push origin --force --all
```

#### Option B: Use BFG Repo-Cleaner

```powershell
# Download BFG: https://rtyley.github.io/bfg-repo-cleaner/

# Run BFG to remove the file
java -jar bfg.jar --delete-files google-services.json

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin --force --all
```

#### Option C: Manual Rebase (If recent commit)

```powershell
# Interactive rebase to remove the commit
git rebase -i 7785ba0a95610857bbc4842f3944f0b3f1872ac5^

# Mark the commit as 'drop' or 'edit' and remove the file
# Then force push
git push origin --force
```

---

## 📋 Current Security Status

### ✅ Protected Files (.gitignore)

Your `.gitignore` correctly excludes:
- `.env` and `.env.*` files
- `lib/firebase_options.dart`
- `lib/config/api_keys.dart`

### ❌ Exposed in Git History

- `android/app/google-services.json` - **Committed in 7785ba0a95**

### ✅ Safe Example Files

These are safe (template files only):
- `.env.example`
- `lib/firebase_options.dart.example`

---

## 🔐 Best Practices Going Forward

### 1. Never Commit Secrets

Files to **NEVER** commit:
- `google-services.json` (Android Firebase config)
- `GoogleService-Info.plist` (iOS Firebase config)
- `.env` files
- `firebase_options.dart`
- Any file containing API keys, tokens, or passwords

### 2. Use Environment Variables

Your app already uses `.env` files correctly:
```env
YOUTUBE_API_KEY=your_actual_key_here
FIREBASE_WEB_API_KEY=your_actual_key_here
```

Keep these in `.env` (ignored by git) and only commit `.env.example` with placeholder values.

### 3. Add Pre-commit Hooks

Install a tool like **git-secrets** or **detect-secrets** to scan for secrets before committing:

```powershell
# Install git-secrets
# https://github.com/awslabs/git-secrets

# Setup for your repo
git secrets --install
git secrets --register-aws
```

### 4. Firebase API Key Restrictions

In Firebase Console, add these restrictions to your API key:

**Application Restrictions:**
- Android apps: Restrict to your package name (`com.example.eco_sustain`)
- Add SHA-1 fingerprints

**API Restrictions:**
- Only enable the APIs you actually use (Auth, Firestore, Storage)

---

## 🧪 Verification Steps

After rotating keys and cleaning history:

### 1. Verify .gitignore Works

```powershell
# Check what git would commit
git status

# google-services.json should NOT appear in "Changes to be committed"
```

### 2. Verify History is Clean

```powershell
# Search for API keys in entire history
git log --all --full-history -- android/app/google-services.json

# Should return nothing after cleanup
```

### 3. Test App with New Keys

1. Download new `google-services.json` from Firebase
2. Place it in `android/app/google-services.json` (git will ignore it)
3. Run the app to verify authentication still works
4. **Never commit this file!**

---

## 📞 If Keys Were Already Leaked

If this is a public repository that was already cloned by others:

1. ✅ Rotate Firebase API keys immediately
2. ✅ Add API restrictions in Firebase Console
3. ✅ Monitor Firebase usage for suspicious activity
4. ✅ Enable Firebase App Check for additional security
5. ✅ Consider creating a new Firebase project if heavily compromised

---

## 🎯 Quick Fix Checklist

- [ ] Rotate Firebase API key in console
- [ ] Download new `google-services.json`
- [ ] Ensure `android/app/google-services.json` is in `.gitignore`
- [ ] Remove file from git history using one of the methods above
- [ ] Force push cleaned history
- [ ] Add API restrictions in Firebase Console
- [ ] Test app with new configuration
- [ ] Inform collaborators to re-clone the repository

---

## 📚 Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/api-keys)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [git-filter-repo](https://github.com/newren/git-filter-repo)

---

**Last Updated:** November 3, 2025  
**Status:** 🔴 Action Required
