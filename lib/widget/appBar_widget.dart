import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class AppbarWidget {
  final String title;
  final BuildContext context;

  AppbarWidget({required this.title, required this.context});

  AppBar build() {
    final canPop = Navigator.canPop(context);
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: canPop,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundImage: AssetImage("assets/icon.png"),
            radius: 16,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}
