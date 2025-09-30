import 'package:flutter/material.dart';

import '../utils/style_utils.dart';

class FoxButton extends StatelessWidget {
  void Function()? onPressed;
  String text;

  FoxButton({super.key, required this.onPressed,required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(FoxThemeButtonActiveBackground),
        foregroundColor: WidgetStateProperty.all(FoxThemeButtonTextColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

}