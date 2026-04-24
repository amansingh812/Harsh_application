import 'package:dotted_separator/dotted_separator.dart';

import 'firestore_data_upload.dart';

class AdminSeedPage extends StatelessWidget {
  const AdminSeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await seedMasterData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Master data uploaded ✅')),
            );
          },
          child: const Text('SEED MASTER DATA'),
        ),
      ),
    );
  }
}
