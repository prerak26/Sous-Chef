import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:souschef_frontend/discover.dart';
import 'package:souschef_frontend/main.dart';
import 'package:souschef_frontend/shoping_list.dart';
import 'package:souschef_frontend/home.dart';
import 'package:souschef_frontend/route_generator.dart';

List<PersistentBottomNavBarItem> _navBarItems() {
  return [
    PersistentBottomNavBarItem(
      
      icon: const Icon(Icons.home),
      title: 'Home',
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/",
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: 'Discover',
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/",
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.add_box),
      title: 'Shopping List',
      routeAndNavigatorSettings: const RouteAndNavigatorSettings(
        initialRoute: "/",
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    ),
  ];
}

class NavigationView extends StatefulWidget {
  final String initalView;
  const NavigationView({super.key, required this.initalView});
  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  bool doRefresh = session.isLogged;
  PersistentTabController _controller = PersistentTabController();
  @override
  void initState() {
    super.initState();
    switch (widget.initalView) {
      case "home":
        _controller = PersistentTabController(initialIndex: 0);
        break;
      case "discover":
        _controller = PersistentTabController(initialIndex: 1);
        break;
      case "shopping-list":
        _controller = PersistentTabController(initialIndex: 2);
        break;
      default:
        _controller = PersistentTabController(initialIndex: 1);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        
        context,
        controller: _controller,
        screens: const [
          HomeView(),
          DiscoverView(),
          ShoppingListView(),
        ],

        items: _navBarItems(),
        onItemSelected: (value) {
          setState(() {
            doRefresh = session.isLogged;
          });
        },
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: (_controller.index==1 || doRefresh) ? true : false,
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
