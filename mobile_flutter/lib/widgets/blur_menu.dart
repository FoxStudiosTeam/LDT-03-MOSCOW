import 'dart:ui';
import 'package:flutter/material.dart';

/// Показывает модальное блюр-меню снизу с кастомным содержимым
Future<void> showBlurBottomSheet({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  double blurSigma = 10.0,
  double backgroundOpacity = 0.2,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    isDismissible: isDismissible,
    builder: (ctx) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (isDismissible) Navigator.pop(context);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: Colors.black.withOpacity(backgroundOpacity),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Material( // Добавляем Material, чтобы Ripple работал
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: builder(context),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
