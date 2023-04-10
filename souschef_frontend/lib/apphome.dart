import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:souschef_frontend/discover.dart';
import 'package:souschef_frontend/login.dart';
import 'package:souschef_frontend/myrecipieholder.dart';
import 'package:souschef_frontend/shoppinglist.dart';
import 'package:souschef_frontend/signup.dart';
import 'package:souschef_frontend/userhome.dart';

List<PersistentBottomNavBarItem> _navBarItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: 'Home',
      //activeColor: Colors.blue,
      //inactiveColor: Colors.grey,
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: "/",
            routes: {
               '/':(context) => const MyHomePage(),
        
                '/signup': (context) => const UserRegistrationPage(),
            },
          ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: 'Discover',
      //activeColor: Colors.blue,
      //inactiveColor: Colors.grey,
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: "/",
            routes: {
               '/':(context) => const MyHomePage(),
        
                '/signup': (context) => const UserRegistrationPage(),
                '/home':(context) => const placePage(),
            },
          ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.add_box),
      title: 'Shopping List',
      //activeColor: Colors.blue,
      //inactiveColor: Colors.grey,
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: "/",
            routes: {
               '/':(context) => const MyHomePage(),
        
                '/signup': (context) => const UserRegistrationPage(),
            },
          ),
    ),
    
  ];
}






class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  

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
  screens:const [
    
    placePage(),
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
  itemAnimationProperties: ItemAnimationProperties(
    duration: Duration(milliseconds: 300),
    curve: Curves.ease,
  ),
  screenTransitionAnimation: ScreenTransitionAnimation(
    animateTabTransition: true,
    curve: Curves.ease,
    duration: Duration(milliseconds: 200),
  ),
  navBarStyle: NavBarStyle.style6,
),

);
}     
  

  
}