import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import '../domain/entities.dart';
import '../screens/object_screen.dart';
import '../di/dependency_container.dart';

class ObjectCard extends StatefulWidget {
  final String title;
  final String address;
  final String projectUuid;
  final ProjectStatus status;
  final IDependencyContainer di;
  final FoxPolygon polygon;
  final String? customer;
  final String? foreman;
  final String? inspector;
  final Color backgroundColor;
  final bool isStatic;

  const ObjectCard({
    super.key,
    required this.title,
    required this.address,
    required this.projectUuid,
    required this.status,
    required this.di,
    required this.polygon,
    required this.customer,
    required this.foreman,
    required this.inspector,
    required this.isStatic,
    this.backgroundColor = Colors.white,
  });

  @override
  State<ObjectCard> createState() => _ObjectCardState();
}

class _ObjectCardState extends State<ObjectCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _showPoints = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
  }

  @override
  void didUpdateWidget(ObjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.polygon.getCenter() != widget.polygon.getCenter()) {
      _mapController.move(widget.polygon.getCenter(), 15.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _showPoints = false;
      }
    });
  }

  void _toggleShowPoints() {
    setState(() {
      _showPoints = !_showPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textAndIconColor = Colors.black;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: widget.backgroundColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ObjectScreen(
                address: widget.address,
                projectUuid: widget.projectUuid,
                di: widget.di,
                status: widget.status,
                polygon: widget.polygon,
                customer: widget.customer,
                foreman: widget.foreman,
                inspector: widget.inspector,
              ),
            ),
          );
        },
        child: Padding(
          // padding: const EdgeInsets.only(top: 6.0, bottom: 8.0, left: 18.0, right: 18.0),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Адрес: ${widget.title}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: textAndIconColor),
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleExpanded,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 3.14159, // 180 градусов в радианах
                          child: Iconify(
                            Mdi.keyboard_arrow_down,
                            color: textAndIconColor,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              widget.status.toRenderingString(),
              const SizedBox(height: 8),

              // Анимированная область раскрытия
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _heightAnimation,
                    axisAlignment: -1.0,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: child,
                    ),
                  );
                },
                child: _buildExpandedContent(textAndIconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(Color textAndIconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Заказчик: ${widget.customer}"),
        Text("Подрядчик: ${widget.foreman}"),
        Text("Ответственный инспектор: ${widget.inspector}"),
        // Анимированная карта
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _expanded ? 200 : 0,
          margin: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.polygon.getCenter(),
                initialZoom: 15,
                interactionOptions: widget.isStatic ? InteractionOptions(
                  flags: InteractiveFlag.none,
                ) : InteractionOptions(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.yourapp',
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: widget.polygon.points,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Кнопка показа точек

        AnimatedOpacity(
          opacity: _expanded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: TextButton.icon(
            onPressed: _toggleShowPoints,
            icon: Iconify(
              _showPoints ? Mdi.keyboard_arrow_up : Mdi.keyboard_arrow_down,
              color: textAndIconColor,
            ),
            label: Text(
              _showPoints ? "Скрыть точки на полигоне" : "Показать точки на полигоне",
              style: TextStyle(color: textAndIconColor),
            ),
          ),
        ),

        // Анимированный список точек
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            height: _showPoints ? 150 : 0,
            child: _showPoints ? _buildPointsList(textAndIconColor) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsList(Color textAndIconColor) {
    return ListView.builder(
      itemCount: widget.polygon.points.length,
      itemBuilder: (context, index) {
        final point = widget.polygon.points[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FoxThemeButtonTextColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Точка ${index + 1}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textAndIconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Широта: ${point.latitude.toStringAsFixed(6)}",
                style: TextStyle(fontSize: 14, color: textAndIconColor),
              ),
              Text(
                "Долгота: ${point.longitude.toStringAsFixed(6)}",
                style: TextStyle(fontSize: 14, color: textAndIconColor),
              ),
            ],
          ),
        );
      },
    );
  }
}