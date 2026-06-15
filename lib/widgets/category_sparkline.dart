import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';

/// Last-30-day daily-total spark line for a single category.
class CategorySparkline extends StatelessWidget {
  final List<Transaction> transactions;
  final Color color;
  final double height;

  const CategorySparkline({
    super.key,
    required this.transactions,
    required this.color,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final spots = _dailySpots(transactions);
    final hasAny = spots.any((s) => s.y > 0);
    final maxY = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);
    return SizedBox(
      height: height,
      child: hasAny
          ? LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: maxY * 1.2 + 1,
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.32,
                    barWidth: 2.5,
                    color: color,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            )
          : Center(
              child: Text(
                AppLocalizations.of(context).sparklineEmpty,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
            ),
    );
  }

  List<FlSpot> _dailySpots(List<Transaction> txs) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 29));
    final totals = List<double>.filled(30, 0);
    for (final t in txs) {
      final day = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      final i = day.difference(start).inDays;
      if (i < 0 || i > 29) continue;
      totals[i] += t.amount;
    }
    return [for (int i = 0; i < 30; i++) FlSpot(i.toDouble(), totals[i])];
  }
}
