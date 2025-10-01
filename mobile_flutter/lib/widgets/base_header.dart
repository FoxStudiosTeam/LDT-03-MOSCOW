import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

const String backIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m15 6l-6 6l6 6"/></svg>';
const String moreIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><path fill="currentColor" d="M14 18a2 2 0 1 1-4 0a2 2 0 0 1 4 0m0-6a2 2 0 1 1-4 0a2 2 0 0 1 4 0m-2-4a2 2 0 1 0 0-4a2 2 0 0 0 0 4" stroke-width="0.4" stroke="currentColor"/></svg>';

const gray600 = Color.fromRGBO(117, 117, 117, 1);
const gray800 = Color.fromRGBO(66, 66, 66, 1);
class BaseHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color lineColor;
  final Color backColor;
  final Color moreColor;
  final BoxShadow? shadow;
  final bool centeredTitle;
  final void Function()? onMore;
  final void Function()? onBack;

  BaseHeader({
    super.key,
    required this.title,
    this.subtitle = "",
    this.centeredTitle = false,
    this.backgroundColor = Colors.white,
    this.primaryTextColor = gray800,
    this.secondaryTextColor = gray600,
    this.backColor = gray800,
    this.lineColor = Colors.black12,
    this.shadow,
    this.onBack,
    this.onMore,
    this.moreColor = gray800,
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
        border: Border(bottom: BorderSide(color: lineColor, width: 1)),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
            ...(onMore != null ? _moreButton(context, onMore!) : []),
          ]
        )
    );
  }

  List<Widget> _moreButton(BuildContext context, void Function() onBack) {
    return [
      Positioned(
        right: 0,
        child: IconButton(
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
            moreIcon, 
            color: moreColor,
          )
        ),
      ),
      Positioned(
        right: preferredSize.height - 32,
        top: 0,
        bottom: 0,
        child: Container(
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                backgroundColor.withAlpha(0),
                backgroundColor,
              ],
            ),
          ),
        ),
      ),
    ];
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
          width: 20,
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
