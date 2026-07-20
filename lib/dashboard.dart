import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:home_ideator_app/Pages/home.dart';
import 'package:home_ideator_app/Pages/shop_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State&lt;Dashboard&gt; {
  int currentIndex = 0;

  // BUG FIX: `final List pages = [...]` is untyped. Using List&lt;Widget&gt;
  // enables compile-time type safety when indexing in `body:`.
  final List&lt;Widget&gt; pages = [
    Home(),
    Shop(),
  ];

  // BUG FIX: `@override` annotation was placed before the field declarations
  // rather than before the `build` method — corrected here.
  @override
  Widget build(BuildContext context) {
    // BUG FIX: Removed the nested MaterialApp. Dashboard is already rendered
    // inside the MaterialApp defined in main.dart. Nesting another MaterialApp
    // creates an isolated Navigator that breaks all route-push calls.
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Image.asset(
            'images/icon.png',
            width: 50,
            height: 70,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        hasNotch: true,
        hasInk: true,
        inkColor: Colors.black12,
        items: &lt;BubbleBottomBarItem&gt;[
          BubbleBottomBarItem(
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.home, color: Colors.black),
              activeIcon:
                  const Icon(Icons.dashboard, color: Colors.blueAccent),
              title: const Text('Home')),
          BubbleBottomBarItem(
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.shop, color: Colors.black),
              activeIcon: const Icon(Icons.shopping_cart,
                  color: Colors.blueAccent),
              title: const Text('Shop')),
        ],
      ),
    );
  }

  void changePage(int value) {
    setState(() {
      currentIndex = value;
    });
  }
}
