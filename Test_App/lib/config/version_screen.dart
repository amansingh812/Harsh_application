import 'package:dotted_separator/dotted_separator.dart';
import 'package:school_scout/config/version_fetch.dart';

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  String version = "";

  @override
  void initState() {
    super.initState();
    getAppVersion().then((v) {
      if (mounted) {
        setState(() => version = v);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cleanVersion = version.split('+').first;

    return Text(
      "Version: $cleanVersion",
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

}
