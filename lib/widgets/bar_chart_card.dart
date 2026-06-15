import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

class BarChartCard extends StatelessWidget {
  final double totalSpent;

  const BarChartCard({super.key, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.statsTotalSpent, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            totalSpent.toStringAsFixed(0),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: BarChart(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 3000,
                minY: 0,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final monthIdx = value.toInt();
                        if (monthIdx < 0 || monthIdx > 11) {
                          return const Text(' ');
                        }
                        final label = DateFormat.MMM(localeStr)
                            .format(DateTime(2000, monthIdx + 1));
                        return Text(label,
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: _getBarGroups(totalSpent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<BarChartGroupData> _getBarGroups(double totalSpent) {
    DateTime now = DateTime.now();
    return [
      BarChartGroupData(
        barsSpace: 10,
        x: (now.month + 6),
        barRods: [
          BarChartRodData(
            toY: 2180,
            color: const Color.fromARGB(255, 196, 218, 237),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
      BarChartGroupData(
        barsSpace: 10,
        x: (now.month + 7),
        barRods: [
          BarChartRodData(
            toY: 1460,
            color: const Color.fromARGB(255, 218, 180, 224),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
      BarChartGroupData(
        barsSpace: 10,
        x: (now.month - 4),
        barRods: [
          BarChartRodData(
            toY: 1340,
            color: const Color.fromARGB(255, 155, 204, 244),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
      BarChartGroupData(
        barsSpace: 11,
        x: (now.month - 3),
        barRods: [
          BarChartRodData(
            toY: 2250,
            color: const Color.fromARGB(255, 233, 174, 244),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
      BarChartGroupData(
        barsSpace: 10,
        x: (now.month - 2),
        barRods: [
          BarChartRodData(
            toY: 1480,
            color: const Color.fromARGB(255, 131, 179, 221),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
      BarChartGroupData(
        barsSpace: 10,
        x: (now.month - 1),
        barRods: [
          BarChartRodData(
            toY: totalSpent,
            color: const Color.fromARGB(255, 229, 149, 244),
            width: 40,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      ),
    ];
  }
}
