import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/reports/reports_provider.dart';
import 'package:mobile_flutter/screens/create_report_screen.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/report_card.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';

class ReportScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectTitle;
  final String projectUuid;
  final bool isNear;
  final List<String> works;

  const ReportScreen({
    super.key,
    required this.di,
    required this.projectTitle,
    required this.projectUuid,
    required this.isNear,
    required this.works,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _token;
  Role? _role;
  bool _loaded = false;
  List<ReportCard> reports = [];

  void leaveHandler() {
    Navigator.pop(context);
  }

  Future<void> _loadAuth() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(
        IAuthStorageProviderDIToken,
      );
      var role = await authStorageProvider.getRole();
      var token = await authStorageProvider.getAccessToken();
      setState(() {
        _token = token;
        _role = roleFromString(role);
      });
    } catch (e) {
      setState(() {
        _token = "NO TOKEN";
        _role = Role.UNKNOWN;
      });
    }
  }

  Future<List<ReportCard>> _loadCards() async {
    final provider = widget.di.getDependency<IReportsProvider>(IReportsProviderDIToken);
    final statuses = await provider.get_statuses();
    final reports = await NetworkUtils.wrapRequest(() => provider.get_reports(widget.projectUuid), context, widget.di);
    setState(() {
      _loaded = true;
    });
    return reports.map((rep) => ReportCard(
      di: widget.di,
      data: rep,
      role: _role,
      statuses: statuses,
    )).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAuth();
    _loadCards().then((cards) {
      setState(() {
        reports = cards;
      });
    });
  }

  void _openReportMenu() {
    showBlurBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.attach_file),
            title: const Text('Создать отчет'),
            onTap: () {
              Navigator.pop(ctx);
              _handleCreateReport();
            },
          ),
        ],
      ),
    );
  }

  void _handleCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportCreationScreen(di: widget.di, address: widget.projectTitle, works: widget.works)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Отчеты",
        subtitle: widget.projectTitle,
        onBack: leaveHandler,
        onMore: ((_role == Role.FOREMAN && widget.isNear) || _role == Role.ADMIN) ? _openReportMenu : null,
      ),
      body: !_loaded ? const Center(child: CircularProgressIndicator())
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: reports.isEmpty
          ? const Center(
            child: Text(
              "Отчетов не обнаружено",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
          : ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => reports[index],
          ),
      ),
    );
  }
}

