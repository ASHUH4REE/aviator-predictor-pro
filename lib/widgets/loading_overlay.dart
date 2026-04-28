import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Lightweight modal loader; show via `LoadingOverlay.show(context)` and dismiss with `pop`.
class LoadingOverlay {
  LoadingOverlay._();

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const Center(
        child: SizedBox(
          height: 56,
          width: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ),
    );
  }

  static void dismiss(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
