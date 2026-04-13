# Mini Reddit V2

A fully-featured Reddit clone built with Flutter and Supabase, showcasing modern mobile app development practices with a clean architecture and beautiful UI.

## Features

### Core Functionality

- **Authentication System** - Complete auth flow with login, signup, password recovery
- **Feed Management** - Hot/New posts with infinite scrolling and real-time updates
- **Community System** - Create, join, and manage communities with member counts
- **Post Management** - Create posts with text, images, links, and voting system
- **Comment System** - Nested comments with voting and real-time interactions
- **User Profiles** - Profile management with avatar/banner uploads
- **Search Functionality** - Unified search across posts, communities, and users
- **Notifications** - Push notifications for post interactions
- **Post Saving** - Save posts for later viewing

### Advanced Features

- **Real-time Updates** - Live voting, comments, and feed updates
- **Image Handling** - Multiple image uploads with compression and caching
- **Deep Linking** - Handle app links for direct post navigation
- **Theme System** - Complete light/dark theme with Reddit-style design
- **Offline Support** - Local caching with Hive for offline viewing
- **Skeleton Loading** - Beautiful loading states throughout the app

## Architecture

### Tech Stack

- **Frontend**: Flutter 3.6+ with Riverpod for state management
- **Backend**: Supabase (PostgreSQL + Realtime + Auth + Storage)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Local Storage**: Hive for caching and offline support
- **Image Processing**: flutter_image_compress for optimization

### Project Structure

```
lib/
|-- core/                    # Shared utilities and configurations
|   |-- constants/          # App constants
|   |-- models/             # Data models (Post, User, Community, etc.)
|   |-- services/           # External services (Supabase, Cache)
|   |-- theme/              # Design system and theming
|   |-- utils/              # Helper functions
|   |-- widgets/            # Reusable UI components
|   `-- riverpod/           # Global providers
|-- features/               # Feature-based architecture
|   |-- auth/               # Authentication flow
|   |-- communities/        # Community management
|   |-- feed/               # Home feed and posts
|   |-- post/               # Post creation and details
|   |-- profile/            # User profiles
|   |-- search/             # Search functionality
|   `-- notifications/      # Push notifications
|-- main.dart               # App entry point
`-- firebase_options.dart   # Firebase configuration
```

### Clean Architecture

The app follows Clean Architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components and state management (Riverpod)
- **Domain Layer**: Business logic and use cases (Repository interfaces)
- **Data Layer**: Data sources and implementations (Supabase integration)

## Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK compatible with Flutter version
- Supabase account and project
- Firebase project (for push notifications)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd mini_reddit_v2
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory:

   ```env
   EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
   EXPO_PUBLIC_SUPABASE_KEY=your_supabase_anon_key
   ```

4. **Database Setup**
   - Import the provided SQL schema from `lib/code.sql`
   - Set up Supabase Auth with appropriate providers
   - Configure storage buckets for images

5. **Firebase Setup**
   - Create a Firebase project
   - Add your app to Firebase
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Cloud Messaging

6. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Supabase Setup

1. Enable Authentication providers (Email, Google, etc.)
2. Set up Row Level Security (RLS) policies
3. Configure Storage buckets for:
   - User avatars
   - Community images
   - Post images

### Firebase Configuration

- Enable Cloud Messaging
- Configure APNs certificates (iOS)
- Set up Firebase service account key

## Key Features Deep Dive

### Authentication System

- Email/password authentication
- Social login options
- Password recovery
- Profile completion flow
- Session management with automatic refresh

### Feed System

- Hot/New post sorting algorithms
- Infinite scroll with pagination
- Real-time post updates
- Community filtering
- Post voting with instant feedback

### Community Features

- Create and manage communities
- Member management system
- Community posts and discussions
- Image and banner uploads
- Member statistics

### Post System

- Multiple post types (Text, Image, Link)
- Rich text editor
- Multiple image uploads with carousel
- Voting system with score calculation
- Comment threading
- Post flairs and categorization

### Search System

- Unified search across all content types
- Real-time search with debouncing
- Trending topics display
- User and community discovery
- Search history and suggestions

## Performance Optimizations

### Image Handling

- Automatic image compression
- Cached network images
- Progressive loading
- Memory-efficient image carousels

### State Management

- Efficient Riverpod providers
- Selective rebuilding
- Local state isolation
- Background data synchronization

### Caching Strategy

- Hive for offline data storage
- Image caching with cached_network_image
- API response caching
- Smart cache invalidation

## UI/UX Features

### Design System

- Reddit-inspired design tokens
- Custom theme system with light/dark modes
- Consistent spacing and typography
- Brand-aligned color scheme

### User Experience

- Smooth animations and transitions
- Skeleton loading states
- Pull-to-refresh functionality
- Haptic feedback
- Accessibility support

## Testing

The app is structured to support comprehensive testing:

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue in the repository
- Check the documentation
- Review the code comments

---

**Built with Flutter and Supabase** - A modern approach to mobile app development.
