import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/formatters.dart';

class DonutSlice {
  final String label;
  final double value;
  final Color color;
  const DonutSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class DonutChartCard extends StatelessWidget {
  final List<DonutSlice> slices;
  final String currencyCode;
  final String currentMonth;

  const DonutChartCard({
    super.key,
    required this.slices,
    required this.currencyCode,
    required this.currentMonth,
  });

  double get _total =>
      slices.fold(0.0, (sum, s) => sum + s.value);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                l.statsTotalExpenses,
                style: const TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(_total, currencyCode, locale: localeStr),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentMonth,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurpleAccent,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 170,
            child: PieChart(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              PieChartData(
                sections: _sections(),
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _sections() {
    if (slices.every((s) => s.value <= 0)) {
      return [
        PieChartSectionData(
          showTitle: false,
          value: 1,
          color: Colors.grey.shade300,
          radius: 30,
        ),
      ];
    }
    return slices
        .where((s) => s.value > 0)
        .map((s) => PieChartSectionData(
              showTitle: false,
              value: s.value,
              color: s.color,
              radius: 30,
            ))
        .toList();
  }
}
