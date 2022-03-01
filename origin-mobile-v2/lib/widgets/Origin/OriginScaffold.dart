import 'package:origin/widgets/Navigation/LeftNavigationMenu.dart';
import 'package:origin/widgets/Navigation/RightNavigationMenu.dart';
import "package:origin/config/auto_loader.dart";
import 'OriginAppBar.dart';

/// Enveloppe générique de l'application Origin
class OriginScaffold extends StatelessWidget {

  final Key key;
  final String title;
  final TabBar bottomTabBar;
  final Widget appbarExtraIcon;
  final Widget body;
  final Widget floatingActionButton;
  final bool isLoading;
  final bool withoutAppBar;

  final String currentViewId;
  final String previousViewId;

  OriginScaffold({
    this.title,
    @required this.currentViewId,
    @required this.body,
    this.key,
    this.withoutAppBar = false,
    this.bottomTabBar,
    this.floatingActionButton,
    this.previousViewId,
    this.isLoading = false,
    this.appbarExtraIcon
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: withoutAppBar ? null : OriginAppBar(
        title: title,
        bottomTabBar: bottomTabBar,
        currentViewId: currentViewId,
        extraIcon: appbarExtraIcon,
      ),
      drawer: LeftNavigationDrawer(currentViewId: currentViewId == OriginConstants.storyViewId ? previousViewId : currentViewId),
      body: !isLoading ? body : Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(solutecRed),
        )
      ),
      endDrawer: RightNavigationDrawer(),
      floatingActionButton: floatingActionButton,
    );
  }

  static const backgroundColor = Color(0xFFFAFAFA);

}