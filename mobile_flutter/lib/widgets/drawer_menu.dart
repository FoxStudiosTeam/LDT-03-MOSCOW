import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/about_screen.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key, required this.di});
  final IDependencyContainer di;

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {

  void changeScreen(WidgetBuilder screen){
    bool isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isCurrent){
      Navigator.push(context, MaterialPageRoute(builder: screen));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            duration: Duration(seconds: 2),
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Электронный цифровой журнал',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Объекты'),
            onTap: () {
              changeScreen((context) => ObjectsScreen(di: widget.di));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('О нас'),
            onTap: () {
              changeScreen((context) => AboutScreen(di: widget.di));
            },
          ),
        ],
      ),
    );
  }
}
