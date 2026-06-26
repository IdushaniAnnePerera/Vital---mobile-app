import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});
  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  final _db = DatabaseService.instance;
  List<Medication> _meds = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _db.getMedications();
    setState(() => _meds = m);
  }

  String _fmtTime(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _addMed() async {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add medication',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Vitamin D)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: doseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 1 tablet)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reminder time',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_fmtTime(time.hour, time.minute)),
                    onPressed: () async {
                      final picked =
                          await showTimePicker(context: ctx, initialTime: time);
                      if (picked != null) setSheet(() => time = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.meds),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save & schedule reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      final med = Medication(
        name: nameCtrl.text.trim(),
        dosage: doseCtrl.text.trim(),
        hour: time.hour,
        minute: time.minute,
      );
      final id = await _db.addMedication(med); // String id from Firestore
      await NotificationService.instance.scheduleDaily(
        id: id,
        title: 'Time for ${med.name}',
        body: med.dosage.isEmpty ? 'Tap to mark as taken' : 'Take ${med.dosage}',
        hour: med.hour,
        minute: med.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder set for ${_fmtTime(med.hour, med.minute)} daily'),
          ),
        );
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.meds,
        onPressed: _addMed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: _meds.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: EmptyState(
                    icon: Icons.medication_outlined,
                    message:
                        'No medications yet.\nAdd one to get a daily reminder.'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final m in _meds)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.meds.withOpacity(0.14),
                          child: const Icon(Icons.medication,
                              color: AppColors.meds),
                        ),
                        title: Text(m.name,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${m.dosage.isEmpty ? "—" : m.dosage} · ${_fmtTime(m.hour, m.minute)} daily'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.inkSoft),
                          onPressed: () async {
                            await NotificationService.instance.cancel(m.id!);
                            await _db.deleteMedication(m.id!);
                            _load();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
