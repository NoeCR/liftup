// Example Sentry configuration file
// Copy this file as sentry_config.dart and replace values as needed

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Example configuration for Sentry
class SentryConfigExample {
  // Replace with your real Sentry DSN
  static const String _dnsKey = 'https://your-dsn@sentry.io/project-id';

  /// Development configuration
  static final SentryFlutterOptions developmentOptions = SentryFlutterOptions(dsn: _dnsKey);

  /// Production configuration
  static final SentryFlutterOptions productionOptions = SentryFlutterOptions(dsn: _dnsKey);

  /// Gets the appropriate configuration based on environment
  static SentryFlutterOptions get options {
    return kDebugMode ? developmentOptions : productionOptions;
  }

  /// Filters events before sending them to Sentry
  static SentryEvent? _beforeSend(SentryEvent event, {Hint? hint}) {
    // Filter development events in production
    if (!kDebugMode && event.environment == 'development') {
      return null;
    }

    // Filter events with sensitive information
    if (_containsSensitiveData(event)) {
      return null;
    }

    // Add additional device information
    event = event.copyWith(tags: {...?event.tags, 'app_name': 'LiftUp', 'platform': defaultTargetPlatform.name});

    return event;
  }

  /// Filters transactions before sending them to Sentry
  static SentryTransaction? _beforeSendTransaction(SentryTransaction transaction, {Hint? hint}) {
    // Filter development transactions in production
    if (!kDebugMode && transaction.environment == 'development') {
      return null;
    }

    return transaction;
  }

  /// Checks whether the event contains sensitive information
  static bool _containsSensitiveData(SentryEvent event) {
    final message = event.message?.formatted.toLowerCase() ?? '';
    final exception = event.exceptions?.firstOrNull?.value?.toLowerCase() ?? '';

    final sensitiveKeywords = ['password', 'token', 'key', 'secret', 'auth', 'credential'];

    return sensitiveKeywords.any((keyword) => message.contains(keyword) || exception.contains(keyword));
  }

  /// Sentry initialization
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        // Basic configuration
        options.dsn = _dnsKey;
        options.debug = kDebugMode;
        options.environment = kDebugMode ? 'development' : 'production';
        options.release = 'liftup@1.0.0+1';

        // Performance configuration
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;

        // Session configuration
        options.enableAutoSessionTracking = true;
        options.maxBreadcrumbs = kDebugMode ? 100 : 50;

        // Filters
        options.beforeSend = _beforeSend as BeforeSendCallback?;
        options.beforeSendTransaction = _beforeSendTransaction as BeforeSendTransactionCallback?;

        // Additional configuration
        options.attachScreenshot = true;
        options.attachViewHierarchy = true;
        options.enableUserInteractionTracing = true;
        options.enableAutoPerformanceTracing = true;
      },
      appRunner: () {
        // The app will run after initialization
      },
    );
  }
}

/*
SETUP INSTRUCTIONS:

1. Create an account at sentry.io
2. Create a new Flutter project
3. Copy the project's DSN
4. Replace 'YOUR_SENTRY_DSN_HERE' with your real DSN
5. Optionally tweak settings as needed:
   - tracesSampleRate: Percentage of transactions to trace (0.0 - 1.0)
   - profilesSampleRate: Percentage of profiles to trace (0.0 - 1.0)
   - maxBreadcrumbs: Max number of breadcrumbs to keep
   - environment: Application environment (development, staging, production)

RECOMMENDED SETTINGS:

Development:
- tracesSampleRate: 1.0 (trace all transactions)
- profilesSampleRate: 1.0 (trace all profiles)
- debug: true (show Sentry logs)

Production:
- tracesSampleRate: 0.1 (trace 10% of transactions)
- profilesSampleRate: 0.1 (trace 10% of profiles)
- debug: false (no Sentry logs)

SECURITY FILTERS:

The system includes automatic filters for:
- Sensitive information (passwords, tokens, etc.)
- Development-only events in production
- User personal data

You can customize these filters in _beforeSend and _containsSensitiveData.
*/
