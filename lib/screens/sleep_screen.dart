import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _db = DatabaseService.instance;
  List<SleepEntry> _entries = [];

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _db.getSleep(days: 7);
    setState(() => _entries = e.reversed.toList());
  }

  double get _avg => _entries.isEmpty
      ? 0
      : _entries.map((e) => e.hours).reduce((a, b) => a + b) /
          _entries.length;

  Future<void> _logSleep() async {
    double hours = 7.5;
    int quality = 3;

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
              Text('Log last night',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hours slept',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${hours.toStringAsFixed(1)} h',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.sleep)),
                ],
              ),
              Slider(
                value: hours,
                min: 0,
                max: 12,
                divisions: 24,
                activeColor: AppColors.sleep,
                label: '${hours.toStringAsFixed(1)} h',
                onChanged: (v) => setSheet(() => hours = v),
              ),
              const SizedBox(height: 12),
              const Text('Quality',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < quality;
                  return IconButton(
                    onPressed: () => setSheet(() => quality = i + 1),
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: AppColors.sleep,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.sleep),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      await _db.upsertSleep(
          SleepEntry(date: _today, hours: hours, quality: quality));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.sleep,
        onPressed: _logSleep,
        icon: const Icon(Icons.bedtime, color: Colors.white),
        label: const Text('Log sleep', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Weekly average',
            child: StatBlock(
              value: _avg.toStringAsFixed(1),
              unit: 'hrs / night',
              caption: _avg >= 7
                  ? "You're hitting healthy sleep"
                  : 'Aim for 7–9 hours',
              color: AppColors.sleep,
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Last 7 nights',
            child: SizedBox(
              height: 180,
              child: _entries.length < 2
                  ? const EmptyState(
                      icon: Icons.bedtime_outlined,
                      message:
                          'Log a couple of nights to see your sleep curve.')
                  : _SleepLine(entries: _entries),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepLine extends StatelessWidget {
  final List<SleepEntry> entries;
  const _SleepLine({required this.entries});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 12,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (v) =>
              const FlLine(color: AppColors.line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 3)),
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
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.sleep,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0x1F3C5C9E), // sleep @ 12%
            ),
            spots: [
              for (var i = 0; i < entries.length; i++)
                FlSpot(i.toDouble(), entries[i].hours),
            ],
          ),
        ],
      ),
    );
  }
}
