# 🚀 Quick Start Guide

## Step 1: Setup Backend
```bash
cd backend_fastapi
pip install -r requirements.txt
# IMPORTANT: Edit .env file with your REAL API keys
python main.py
```

## Step 2: Run Frontend
```bash
cd english_learning_ai
flutter run
```

## 🔧 Common Issues & Fixes

### Issue: "Backend not responding"
**Fix**: Make sure backend is running on localhost:8000

### Issue: "Voice input not working"  
**Fix**: Grant microphone permissions in system settings

### Issue: "API errors"
**Fix**: Add real API keys to backend_fastapi/.env

### Issue: "Build errors"
**Fix**: Run `flutter pub get` and `flutter packages pub run build_runner build`

## 📱 Testing
1. Start backend first
2. Run frontend 
3. Test with simple text: "Hello, how are you?"
4. Test voice input (requires microphone permission)

## 🎯 Expected Behavior
- App should load home screen
- Navigate to chat screen
- Send text messages and get AI responses
- Voice input should work (with permissions)
