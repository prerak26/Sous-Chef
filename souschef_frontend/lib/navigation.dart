import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:souschef_frontend/discover.dart';
import 'package:souschef_frontend/auth_home.dart';
import 'package:souschef_frontend/auth_shop.dart';
import 'package:souschef_frontend/signup.dart';

List<PersistentBottomNavBarItem> _navBarItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: 'Home',
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/",
        routes: {
          '/': (context) => const NavigationWidget(),
          '/signup': (context) => const SignupPage(),
        },
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: 'Discover',
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/",
        routes: {
          '/': (context) => const NavigationWidget(),
          '/signup': (context) => const SignupPage(),
        },
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.add_box),
      title: 'Shopping List',
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        initialRoute: "/",
        routes: {
          '/': (context) => const NavigationWidget(),
          '/signup': (context) => const SignupPage(),
        },
      ),
    ),
  ];
}

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});
  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  PersistentTabController _controller = PersistentTabController();
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: const [
          AuthHomePage(),
          DiscoverPage(),
          ShoppingPage(),
        ],
        items: _navBarItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style6,
      ),
    );
  }
}
