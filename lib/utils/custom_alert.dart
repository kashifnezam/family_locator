import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../main.dart';

class CustomAlert {
  /// Helper to safely get context
  static BuildContext? get _context {
    if (navigatorKey.currentContext == null ||
        !navigatorKey.currentState!.mounted) {
      debugPrint("Alert context unavailable");
      return null;
    }
    return navigatorKey.currentContext;
  }

  /// Success Alert
  static void successAlert(String text, {String? title}) {
    final context = _context;
    if (context == null) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: text,
      title: title,
    );
  }

  /// Error Alert
  static void errorAlert(String text, {String title = "Error"}) {
    final context = _context;
    if (context == null) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: text,
      title: title,
    );
  }

  /// Loading Alert
  static void loadAlert(String text) {
    final context = _context;
    if (context == null) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: text,
    );
  }

  /// Dismiss Alert
  static void dismissAlert() {
    final context = _context;
    if (context == null) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Confirmation Alert (returns Future<bool>)
  static Future<bool> confirmAlert(String text, {
    String title = "Confirm",
    String confirmText = "Yes",
    String cancelText = "No",
  }) async {
    final context = _context;
    if (context == null) return false;

    final completer = Completer<bool>();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      confirmBtnText: confirmText,
      cancelBtnText: cancelText,
      onConfirmBtnTap: () {
        completer.complete(true);
        dismissAlert();
      },
      onCancelBtnTap: () {
        completer.complete(false);
        dismissAlert();
      },
    );

    return completer.future;
  }

  /// Custom Alert with Options
  static void customAlert({
    required QuickAlertType type,
    required String text,
    String? title,
    String? confirmBtnText,
    Function? onConfirm,
  }) {
    final context = _context;
    if (context == null) return;

    QuickAlert.show(
      context: context,
      type: type,
      text: text,
      title: title,
      confirmBtnText: confirmBtnText ?? "Confirm",
      onConfirmBtnTap: onConfirm != null ? () => onConfirm() : null,
    );
  }
}