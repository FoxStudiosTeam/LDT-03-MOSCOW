import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';

const String backIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m15 6l-6 6l6 6"/></svg>';

class BaseHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color lineColor;
  final Color backColor;
  final BoxShadow? shadow;
  final bool centeredTitle;
  final void Function()? onBack;

  const BaseHeader({
    super.key,
    required this.title,
    this.subtitle = "",
    this.centeredTitle = false,
    this.backgroundColor = Colors.white,
    this.primaryTextColor = Colors.black,
    this.secondaryTextColor = Colors.black,
    this.backColor = Colors.black,
    this.lineColor = Colors.black12,
    this.shadow,
    this.onBack
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: preferredSize.height + topPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: lineColor, width: 1), top: BorderSide(color: lineColor, width: 1)),
      ),
        child: Stack(
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [Flexible(
                    child: 
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 22,
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ],
                    )
                  )
                ),
              ],
            ),
            ...(onBack != null ? _backButton(context, onBack!) : []),
          ]
        )
    );
  }

  List<Widget> _backButton(BuildContext context, void Function() onBack) {
    return [
      IconButton(
        padding: EdgeInsets.all(0.0),
        iconSize: 40,
        constraints: BoxConstraints(
          minHeight: preferredSize.height - 2,
          maxHeight: preferredSize.height - 2,
          minWidth: preferredSize.height - 32,
          maxWidth: preferredSize.height - 32,
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backgroundColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: onBack, 
        icon: Iconify(
          backIcon, 
          color: backColor,
        )
      ),
      Positioned(
        left: preferredSize.height - 32,
        top: 0,
        bottom: 0,
        child: Container(
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                backgroundColor,
                backgroundColor.withAlpha(0),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
