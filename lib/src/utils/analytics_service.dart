import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnalyticsEvent {

  AnalyticsEvent(this.name, [this.params]);
  final String name;
  final Map<String, Object>? params;

  @override
  String toString() {
    if (params == null || params!.isEmpty) {
      return name;
    } else {
      return "$name {${params!.entries.map((entry) => "${entry.key} = ${entry.value}").join(', ')}}";
    }
  }
}

class AnalyticsService {

  AnalyticsService._();
  static final AnalyticsService _instance = AnalyticsService._();

  static AnalyticsService get() => _instance;

  final MethodChannel _platform = const MethodChannel('com.simpleinnovaton.diary/logging');
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    // NOTE: some pieces of code were copied from https://pub.dev/packages/flutter_crashlytics
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);

      Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
    };
  }



  Future<void> trackEvent(AnalyticsEvent event) async {

    try {
      await _platform.invokeMethod(
        'trackEvent',
        <String, Object>{
          'name': event.name,
          'params': event.params ?? <String, Object>{},
        },
      );
    } on MissingPluginException catch (_) {
      // ignore, should happen only in tests
    }
  }

}

class CopyPasteEvents {
  static AnalyticsEvent copy(SelectionChangedCause cause) =>
      AnalyticsEvent('NoteCopyText', <String, String>{'cause': cause.name});
  static AnalyticsEvent paste(SelectionChangedCause cause) =>
      AnalyticsEvent('NotePasteText', <String, String>{'cause': cause.name});

}