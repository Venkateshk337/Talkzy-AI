# English Learning AI App

A comprehensive English learning application specially designed for Kannada speakers, featuring AI-powered grammar correction and conversation practice.

## Features

- **Multi-language Support**: Supports English, Kannada, and Kanglish (Kannada typed in English letters)
- **Dual Learning Modes**: 
  - Grammar Correction Mode
  - Conversation Practice Mode
- **Personalized Learning**: Adapts to user's English level and learning goals
- **Voice Input**: Speech-to-text functionality for hands-free practice
- **AI-Powered**: Uses Google Gemini and OpenAI with intelligent fallback
- **Real-time Feedback**: Confidence scores and friendly explanations
- **Beginner-Friendly**: Simple, encouraging interface for learners

## Architecture

### Frontend (Flutter)
- **Screens**: Home screen with settings, Chat screen for practice
- **Widgets**: Reusable message bubbles, input fields, mode selectors
- **Services**: API communication, audio recording, state management
- **Models**: Data structures for messages and responses

### Backend (FastAPI)
- **AI Integration**: Gemini and OpenAI services with fallback mechanism
- **Smart Prompts**: Context-aware system prompts based on user settings
- **REST API**: Clean endpoints for frontend communication
- **Error Handling**: Comprehensive error management and logging

## Project Structure

```
english_learning_app/
├── frontend_flutter/
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   └── chat_screen.dart
│   │   ├── widgets/
│   │   │   ├── message_bubble.dart
│   │   │   └── input_field.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── audio_service.dart
│   │   ├── models/
│   │   │   └── message_model.dart
│   │   ├── utils/
│   │   │   └── constants.dart
│   │   └── main.dart
│   └── pubspec.yaml
├── backend_fastapi/
│   ├── main.py
│   ├── services/
│   │   ├── ai_service.py
│   │   ├── gemini_service.py
│   │   └── openai_service.py
│   ├── routes/
│   │   └── english_routes.py
│   ├── prompts/
│   │   └── system_prompt.py
│   ├── models/
│   │   └── response_models.py
│   ├── requirements.txt
│   └── .env
└── README.md
```

## Setup Instructions

### Frontend (Flutter)

1. **Install Dependencies**
   ```bash
   cd english_learning_ai
   flutter pub get
   flutter packages pub run build_runner build
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

### Backend (FastAPI)

1. **Install Python Dependencies**
   ```bash
   cd backend_fastapi
   pip install -r requirements.txt
   ```

2. **Configure Environment Variables**
   Edit `.env` file and add your API keys:
   ```env
   OPENAI_API_KEY=your_openai_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

3. **Run the Server**
   ```bash
   python main.py
   ```

The API will be available at `http://localhost:8000`

## API Endpoints

- `GET /` - Root endpoint with API information
- `GET /health` - Health check with service status
- `GET /status` - Detailed API and service status
- `POST /api/correct` - Main English correction endpoint

### Request Format (POST /api/correct)

```json
{
  "text": "naan ige office ge hogidhini",
  "user_language": "kannada",
  "english_level": "beginner",
  "learning_goal": "daily_conversation",
  "mode": "correction"
}
```

### Response Format

```json
{
  "mode": "correction",
  "original_text": "naan ige office ge hogidhini",
  "language_detected": "kannada",
  "corrected_sentence": "I am going to the office.",
  "short_explanation": "Use 'I am going' for present continuous action.",
  "motivation": "Good practice!",
  "confidence": 0.95,
  "tone": "friendly"
}
```

## Configuration

### AI Services

The app supports both Google Gemini and OpenAI with automatic fallback:

1. **Primary Service**: Set via `PRIMARY_AI_SERVICE` environment variable
2. **Fallback Service**: Set via `FALLBACK_AI_SERVICE` environment variable
3. **API Keys**: Configure in `.env` file

### User Personalization

The AI adapts based on:
- **English Level**: Beginner, Intermediate, Advanced
- **Learning Goal**: Daily Conversation, Interview Preparation, General Improvement
- **Preferred Language**: English, Kannada, Kanglish

## Development

### Adding New Features

1. **Frontend**: Add new widgets in `lib/widgets/` and screens in `lib/screens/`
2. **Backend**: Add new services in `services/` and routes in `routes/`
3. **AI Prompts**: Modify `prompts/system_prompt.py` for behavior changes

### Testing

- Frontend: `flutter test`
- Backend: `pytest` (add pytest to requirements.txt for testing)

## Security Notes

- API keys are loaded from environment variables
- CORS is configured for development (restrict in production)
- Input validation and sanitization implemented
- Error messages don't expose sensitive information

## Performance Considerations

- Frontend uses efficient state management
- Backend implements request timeout and retry logic
- AI services are called asynchronously
- Response caching can be added for frequently used corrections

## Future Enhancements

- **Offline Mode**: Local grammar checking for basic corrections
- **Progress Tracking**: User learning analytics and progress reports
- **Multi-user Support**: User accounts and personalized profiles
- **Voice Output**: Text-to-speech for pronunciation practice
- **Cultural Context**: More Kannada-specific learning content
- **Gamification**: Points, badges, and learning streaks

## Support

For issues and feature requests, please check the project documentation or contact the development team.

## License

This project is licensed under the MIT License.
