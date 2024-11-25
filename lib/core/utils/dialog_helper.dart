import 'package:flutter/material.dart';
import '../../views/widgets/customAlertDialog.dart';

class DialogHelper {
  // Dialog Sukses
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  // Dialog Error
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  // Dialog Loading
  static void showLoadingDialog({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomAlertDialog(
        title: 'Mohon Tunggu',
        message: 'Sedang memproses...',
        isLoading: true,
      ),
    );
  }

  // Dialog Konfirmasi
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: confirmText,
        onPressed: onConfirm,
        secondaryButtonText: cancelText,
        onSecondaryPressed: onCancel ?? () => Navigator.pop(context),
      ),
    );
  }
}
