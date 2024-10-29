import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class CustomAlert {
  static void successAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  static void errorAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: text,
    );
  }

  static void loadAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: text,
    );
  }

  static void dismissAlert(BuildContext context) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  static Future<bool> confirmAlert(BuildContext context, String text) async {
    final completer = Completer<bool>();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      text: text,
      onCancelBtnTap: () {
        completer.complete(false);
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
      onConfirmBtnTap: () {
        completer.complete(true);
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
    );

    return completer.future;
  }
}
