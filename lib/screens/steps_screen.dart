import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});
  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final _db = DatabaseService.instance;
  List<StepEntry> _entries = [];
  final _goal = 8000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _db.getSteps(days: 7);
    setState(() => _entries = e.reversed.toList());
  }

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  StepEntry? get _todayEntry {
    for (final e in _entries) {
      if (e.date == _today) return e;
    }
    return null;
  }

  Future<void> _logSteps() async {
    final controller = TextEditingController(
      text: _todayEntry?.steps.toString() ?? '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Today's steps"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 6500'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text) ?? 0),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _db.upsertSteps(StepEntry(date: _today, steps: result));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayEntry?.steps ?? 0;
    final progress = (today / _goal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Steps')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.steps,
        onPressed: _logSteps,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Log steps", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Today',
            trailing: Text('Goal $_goal',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatBlock(
                  value: NumberFormat.decimalPattern().format(today),
                  unit: 'steps',
                  caption:
                      '${(progress * 100).round()}% of your daily goal',
                  color: AppColors.steps,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.line,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.steps),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Last 7 days',
            child: SizedBox(
              height: 180,
              child: _entries.isEmpty
                  ? const EmptyState(
                      icon: Icons.directions_walk,
                      message: 'Log your steps to see your weekly trend.')
                  : _WeeklyBars(entries: _entries, goal: _goal),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  final List<StepEntry> entries;
  final int goal;
  const _WeeklyBars({required this.entries, required this.goal});

  @override
  Widget build(BuildContext context) {
    final maxY = (entries.map((e) => e.steps).fold(0, (a, b) => a > b ? a : b))
        .toDouble();
    return BarChart(
      BarChartData(
        maxY: (maxY < goal ? goal : maxY) * 1.15,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox();
                final d = DateTime.parse(entries[i].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('E').format(d),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.inkSoft)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: entries[i].steps.toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(6),
                color: AppColors.steps,
              ),
            ]),
        ],
      ),
    );
  }
}
