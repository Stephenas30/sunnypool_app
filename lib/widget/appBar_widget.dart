import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class AppbarWidget {
  final String title;
  final BuildContext context;
    
  AppbarWidget({required this.title, required this.context});

  AppBar build() {
    return AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.png"),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      );
  }

}