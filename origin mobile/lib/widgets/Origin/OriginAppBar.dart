import "package:origin/config/auto_loader.dart";
import 'package:origin/widgets/Navigation/NotificationButton.dart';

/// AppBar générique de l'application Origin
class OriginAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String title;
  final TabBar bottomTabBar;
  final String currentViewId;
  final Widget extraIcon;

  OriginAppBar({
    Key key,
    @required this.title,
    @required this.currentViewId,
    this.bottomTabBar,
    this.extraIcon,
  }) : preferredSize = bottomTabBar != null ? Size.fromHeight(kToolbarHeight + kTextTabBarHeight) : Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(title ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (BuildContext context) {
            return currentViewId == OriginConstants.storyViewId ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { Navigator.of(context).pop(); },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip
            ) : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip
            );
          },
        ),
        actions: [
          extraIcon != null ? Builder(
            builder: (context) => extraIcon
          ) : Text(""),
          Builder(
            builder: (context) => NotificationButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip
            )
          )
        ],
        centerTitle: true,
        bottom: bottomTabBar
    );
  }

}