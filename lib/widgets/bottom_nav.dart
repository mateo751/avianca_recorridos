import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_recorridos_app/auth/login_page.dart';
import 'package:taxi_recorridos_app/page/home_page.dart';
import 'package:taxi_recorridos_app/page/recorridos_page.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(user: FirebaseAuth.instance.currentUser!),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => RecorridosPage(user: FirebaseAuth.instance.currentUser!),
          ),
        );
        break;
      case 2:
        await FirebaseAuth.instance.signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A40),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color:
                      widget.selectedIndex == 0
                          ? Colors.cyanAccent
                          : Colors.white70,
                ),
                onPressed: () => _onItemTapped(context, 0),
              ),
              const SizedBox(width: 60),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color:
                      widget.selectedIndex == 2
                          ? Colors.cyanAccent
                          : Colors.white70,
                ),
                onPressed: () => _onItemTapped(context, 2),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () => _onItemTapped(context, 1),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00EFFF), Color(0xFF3B8AC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent,
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
