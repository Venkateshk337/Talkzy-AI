# English Learning AI - Project Structure

## 📁 Final Project Structure

```
english-learning-app/
│
├── frontend_flutter/                 # Flutter frontend application
│   ├── lib/
│   │   ├── config/                   # API configuration
│   │   ├── models/                   # Data models
│   │   ├── services/                 # Business logic services
│   │   ├── screens/                  # UI screens
│   │   ├── utils/                    # Utility functions
│   │   └── widgets/                  # Reusable widgets
│   ├── android/                      # Android-specific files
│   ├── ios/                          # iOS-specific files
│   ├── web/                          # Web-specific files
│   ├── pubspec.yaml                  # Flutter dependencies
│   └── README.md                      # Flutter-specific README
│
├── backend_fastapi/                  # FastAPI backend application
│   ├── main.py                       # FastAPI application entry point
│   ├── routes/                       # API route definitions
│   │   ├── english_routes.py         # English correction endpoints
│   │   └── voice_routes.py           # Voice transcription endpoints
│   ├── services/                     # Business logic services
│   │   ├── ai_service.py             # AI service orchestration
│   │   ├── gemini_service.py         # Google Gemini integration
│   │   ├── openai_service.py         # OpenAI integration
│   │   └── whisper_service.py        # Whisper transcription
│   ├── models/                       # Pydantic models
│   │   └── response_models.py        # Request/Response models
│   ├── prompts/                      # AI prompt templates
│   ├── utils/                        # Backend utilities
│   ├── requirements.txt              # Python dependencies
│   └── .env                          # Environment variables
│
├── README.md                         # Main project README
├── .gitignore                        # Git ignore rules
└── STARTUP.md                        # Setup and startup guide
```

## 🚀 Key Features Implemented

### Hybrid Voice Processing
- **Android**: Local speech recognition with `speech_to_text`
- **Flutter Web**: Audio recording → Whisper transcription → Gemini correction
- **Platform Detection**: Automatic routing based on `kIsWeb`

### Cross-Platform API Configuration
- **Flutter Web**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000`
- **Physical Device**: `http://YOUR_PC_LOCAL_IP:8000`
- **Desktop**: `http://localhost:8000`

### Backend Services
- **Whisper Service**: Lightweight transcription using `faster-whisper` (tiny model)
- **AI Services**: Gemini primary, OpenAI fallback
- **Voice Routes**: `/voice/transcribe`, `/voice/status`
- **Error Handling**: Detailed error messages with proper validation

### Frontend Services
- **Audio Service**: Hybrid voice processing with platform detection
- **Web Audio Service**: Flutter Web audio recording and upload
- **API Service**: Cross-platform HTTP client with improved error handling
- **Configuration Management**: Platform-aware URL configuration

## 🔧 Setup Instructions

### Backend Setup
```bash
cd backend_fastapi
pip install -r requirements.txt
cp .env.example .env  # Add your API keys
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Frontend Setup
```bash
cd frontend_flutter
flutter pub get
flutter run
```

## 🌐 Platform-Specific Notes

### Flutter Web
- Uses Whisper upload approach
- Requires backend running on `localhost:8000`
- Audio recording in WAV format

### Android Emulator
- Uses local speech recognition
- Backend URL: `http://10.0.2.2:8000`
- Faster response times

### Physical Android Device
- Backend URL: `http://YOUR_PC_LOCAL_IP:8000`
- Must be on same WiFi network as development machine
- Backend must run with `--host 0.0.0.0`

## 🛠️ Development Workflow

1. **Backend Development**: Focus on `backend_fastapi/` directory
2. **Frontend Development**: Focus on `frontend_flutter/` directory
3. **Voice Features**: Implement in both `services/` directories
4. **API Changes**: Update models in `backend_fastapi/models/` and services accordingly

## 📋 Dependencies

### Flutter (frontend_flutter/pubspec.yaml)
- `speech_to_text`: Android voice recognition
- `record`: Audio recording
- `http`: HTTP client
- `permission_handler`: Microphone permissions

### Python (backend_fastapi/requirements.txt)
- `fastapi`: Web framework
- `faster-whisper`: Speech transcription
- `google-genai`: Gemini API (updated package)
- `openai`: OpenAI API
- `python-multipart`: File upload support

## 🔒 Environment Variables

Create `backend_fastapi/.env`:
```
GEMINI_API_KEY=your_gemini_api_key
OPENAI_API_KEY=your_openai_api_key
PRIMARY_AI_SERVICE=gemini
FALLBACK_AI_SERVICE=openai
```

## 🐛 Troubleshooting

### Common Issues
1. **422 Validation Errors**: Fixed with optional request fields
2. **Connection Issues**: Check platform-specific URLs
3. **Permission Errors**: Ensure microphone permissions granted
4. **Backend Busy**: Use ThreadPoolExecutor for better performance

### Debug Mode
- Frontend: Detailed error messages with status codes
- Backend: Comprehensive logging with service status
- Voice: Step-by-step transcription status

## 📱 Testing

### Voice Features
- **Android**: Test speech recognition locally
- **Web**: Test audio upload and transcription
- **Cross-platform**: Verify API configuration works

### API Endpoints
- `POST /api/correct`: English text correction
- `POST /voice/transcribe`: Audio transcription
- `GET /voice/status`: Service health check
- `GET /health`: Backend health check
