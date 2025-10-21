import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'sentry_dsn_config.dart';

/// Sentry configuration for the Liftly application
class SentryConfig {
  // Use DSN configured from SentryDsnConfig
  static String get _dnsKey => SentryDsnConfig.dsn;

  /// Development configuration
  static final SentryFlutterOptions developmentOptions = SentryFlutterOptions(
    dsn: _dnsKey,
  );

  /// Production configuration
  static final SentryFlutterOptions productionOptions = SentryFlutterOptions(
    dsn: _dnsKey,
  );

  /// Gets the appropriate configuration based on environment
  static SentryFlutterOptions get options {
    return kDebugMode ? developmentOptions : productionOptions;
  }

  /// Filters events before sending them to Sentry
  static FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
    // Filter development events in production
    if (!kDebugMode && event.environment == 'development') {
      return null;
    }

    // Filter events that contain sensitive information
    if (_containsSensitiveData(event)) {
      return null;
    }

    // Add additional device information
    event = event.copyWith(
      tags: {
        ...?event.tags,
        'app_name': 'Liftly',
        'platform': defaultTargetPlatform.name,
      },
    );

    return event;
  }

  /// Filters transactions before sending them to Sentry
  static FutureOr<SentryTransaction?> _beforeSendTransaction(
    SentryTransaction transaction,
  ) {
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

    final sensitiveKeywords = [
      'password',
      'token',
      'key',
      'secret',
      'auth',
      'credential',
    ];

    return sensitiveKeywords.any(
      (keyword) => message.contains(keyword) || exception.contains(keyword),
    );
  }

  /// Sentry initialization with fixed configuration to avoid type conflicts
  static Future<void> initialize({void Function()? appRunner}) async {
    // Get package info for release version
    PackageInfo? packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      // Ignore package info errors
    }

    await SentryFlutter.init((options) {
      // Basic configuration
      options.dsn = _dnsKey;
      options.debug = kDebugMode && SentryDsnConfig.isDebugLoggingEnabled;
      options.environment = SentryDsnConfig.environment;

      // Set release info from package info
      if (packageInfo != null) {
        try {
          options.release = '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
        } catch (e) {
          // Fallback to static version if package info fails
          options.release = 'liftly@1.0.0+1';
        }
      } else {
        // Fallback to static version if package info is not available
        options.release = 'liftly@1.0.0+1';
      }

      // Performance configuration
      options.tracesSampleRate = SentryDsnConfig.tracesSampleRate;
      options.profilesSampleRate = SentryDsnConfig.profilesSampleRate;

      // Session configuration
      options.enableAutoSessionTracking = true;
      options.maxBreadcrumbs = kDebugMode ? 100 : 50;

      // Filters
      options.beforeSend = _beforeSend;
      options.beforeSendTransaction =
          _beforeSendTransaction as BeforeSendTransactionCallback?;

      // Additional configuration
      options.attachScreenshot = SentryDsnConfig.isScreenshotsEnabled;
      options.attachViewHierarchy = SentryDsnConfig.isViewHierarchyEnabled;
      options.enableUserInteractionTracing = true;

      // Disable problematic features that cause type conflicts
      options.enableAutoPerformanceTracing = false;
    }, appRunner: appRunner);
  }
}
