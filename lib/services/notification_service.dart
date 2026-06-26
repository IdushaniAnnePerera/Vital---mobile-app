import 'package:flutter/foundation.dart' show kIsWeb;

/// Notification stub — no-op on web (local notifications aren't supported).
/// On mobile you can extend this with flutter_local_notifications if needed.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    if (kIsWeb) return;
    // TODO: add flutter_local_notifications init for Android/iOS
  }

  Future<void> scheduleDaily({
    required String id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    // TODO: schedule daily notification for Android/iOS
  }

  Future<void> cancel(String id) async {
    if (kIsWeb) return;
    // TODO: cancel notification for Android/iOS
  }
}
