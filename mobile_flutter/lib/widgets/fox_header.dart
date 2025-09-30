import 'package:flutter/material.dart';

class FoxHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color lineColor;

  const FoxHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leftIcon,
    this.rightIcon,
    this.backgroundColor = Colors.white,
    this.primaryTextColor = Colors.black,
    this.secondaryTextColor = Colors.black,
    this.lineColor = Colors.black12,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      height: preferredSize.height + topPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: lineColor, width: 1)),
      ),
      child: Row(
        children: [
          if (leftIcon != null) ...[leftIcon!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          if (rightIcon != null) ...[const SizedBox(width: 12), rightIcon!],
        ],
      ),
    );
  }
}
