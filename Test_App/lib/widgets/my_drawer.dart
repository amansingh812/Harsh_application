import 'package:flutter/material.dart';
import 'package:school_scout/widgets/my_drawer_tile.dart';
import 'package:school_scout/screens/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          //app logo
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          //home list title
          MyDrawerTile(
            text: "Home",
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),

          //settings list
          MyDrawerTile(
            text: "Settings",
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ));
            },
          ),
          const Spacer(),
          //logout
          MyDrawerTile(
            text: "Logout",
            icon: Icons.logout,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
