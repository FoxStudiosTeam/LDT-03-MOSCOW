import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/object/object_provider.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/ocr/camera.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/object_card.dart';

import '../di/dependency_container.dart';

class ObjectsScreen extends StatefulWidget {
  final IDependencyContainer di;

  const ObjectsScreen({super.key, required this.di});

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  String? _token; // Переменная для хранения токена
  List<ObjectCard> data = [];

  @override
  void initState() {
    super.initState();

    // Получаем токен асинхронно
    _loadToken();
    _loadCards().then((cards) {
      setState(() {
        data = cards;
      });
    });
  }

  Future<void> _loadToken() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(
        IAuthStorageProviderDIToken,
      );
      var token = await authStorageProvider.getRefreshToken();
      setState(() {
        _token = token;
      });
    } catch (e) {
      setState(() {
        _token = "NO TOKEN";
      });
    }
  }

  Future<void> _leave() async {
    await widget.di
        .getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken)
        .clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen(di: widget.di)),
    );
  }

  Future<List<ObjectCard>> _loadCards() async {
    var objectsProvider = widget.di.getDependency<IObjectsProvider>(IObjectsProviderDIToken);


    var cardsResponse = await objectsProvider.getObjects("", 0);

    var cards = cardsResponse.items.map((project) {
      return ObjectCard(
        title: project.address, // или любое другое поле из Project
        content: "Статус: ${project.status.name}", // пример контента
        di: widget.di,
        polygon: project.polygon!,
      );
    }).toList();
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Iconify(Tabler.menu_2, color: Colors.black87, size: 32),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text('ЭСЖ'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OcrCameraScreen()));
            },
            child: Text("OCR"),
          ),
          data.isEmpty
            ? Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => data[index],
                ),
              ),
        ],
      ),
      drawer: DrawerMenu(di: widget.di)
    );
  }
}
