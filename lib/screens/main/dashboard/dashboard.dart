import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900.withOpacity(0.9),
            Colors.blueGrey.shade800.withOpacity(0.9),
          ],
        ),
      ),
      child: Scaffold(
  backgroundColor: Colors.transparent,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Logo + Teks
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/Logo_BNPB.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sumber Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const OccurrenceChartCard(limit: 50),
          const SizedBox(height: 20),
          const DisasterSummaryCard(),
          const SizedBox(height: 20),
          const DamageLossLineChartCard(limit: 311),

          
        ],
      ),
    ),
  ),
),

    );
  }
}

class StyledCard extends StatelessWidget {
  final Widget child;
  const StyledCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueGrey.shade800.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class OccurrenceChartCard extends StatelessWidget {
  final int limit;
  const OccurrenceChartCard({Key? key, this.limit = 50}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = DisasterService();
    return FutureBuilder<List<DisasterOccurrence>>(
      future: service.fetchDisasterOccurrences(limit: limit),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return StyledCard(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.white)));
        }
        final data = snap.data;
        if (data == null || data.isEmpty) {
          return const StyledCard(child: Text('No data available', style: TextStyle(color: Colors.white)));
        }

        final counts = <int, double>{};
        for (var item in data) {
          item.yearlyOccurrences.forEach((yearStr, value) {
            final year = int.tryParse(yearStr.split('.').first) ?? 0;
            counts[year] = (counts[year] ?? 0) + value.toDouble();
          });
        }
        final years = counts.keys.toList()..sort();
        final spots = years.asMap().entries.map(
          (e) => FlSpot(e.key.toDouble(), counts[years[e.key]]!),
        ).toList();

        return StyledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah Kejadian Bencana per Tahun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: years.length * 50.0,
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString()[0], // hanya ambil 1 angka depan
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= years.length) return const SizedBox();
                              return Transform.rotate(
                                angle: 0.5,
                                child: Text(
                                  years[idx].toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      minX: 0,
                      maxX: (years.length - 1).toDouble(),
                      minY: 0,
                      maxY: counts.values.reduce((a, b) => a > b ? a : b) * 1.2,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.tealAccent,
                          belowBarData: BarAreaData(show: true, color: Colors.tealAccent.withOpacity(0.2)),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DisasterSummaryCard extends StatelessWidget {
  const DisasterSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = DisasterService();
    return FutureBuilder<List<DisasterOccurrence>>(
      future: service.fetchDisasterOccurrences(limit: 9),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return StyledCard(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const StyledCard(child: Text('No data available', style: TextStyle(color: Colors.white)));
        }

        final Map<String, double> totalByDisaster = {};

        for (var item in data) {
          double total = 0;
          item.yearlyOccurrences.forEach((year, value) {
            total += value.toDouble();
          });
          totalByDisaster[item.disasterType] = total;
        }

        final disasterTypes = totalByDisaster.keys.toList();
        final spots = disasterTypes.asMap().entries.map(
          (e) => BarChartRodData(
            toY: totalByDisaster[disasterTypes[e.key]] ?? 0,
            color: Colors.tealAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ).toList();

        return StyledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  'Total Kejadian Bencana 2010–2024',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16), // Tambahkan lebih banyak ruang
              SizedBox(
                height: 320, // Tinggi ditambah untuk memberi ruang teks
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: disasterTypes.length * 100, // Lebar per item ditambah
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 40.0), // Padding atas dan bawah
                      child: BarChart(
                        BarChartData(
                          backgroundColor: Colors.transparent,
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    v.toInt().toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30, // Ruang tambahan untuk label bawah
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= disasterTypes.length) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0), // Padding atas untuk label
                                    child: SizedBox(
                                      width: 80, // Lebar tetap untuk label
                                      child: Transform.rotate(
                                        angle: -0.4, // Sudut rotasi dikurangi
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          disasterTypes[idx],
                                          style: const TextStyle(
                                            fontSize: 11, // Ukuran font sedikit lebih besar
                                            color: Colors.white,
                                            height: 1.2, // Tinggi baris
                                          ),
                                          maxLines: 2, // Maksimal 2 baris
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: List.generate(
                            disasterTypes.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [spots[index]],
                            ),
                          ),
                          alignment: BarChartAlignment.spaceAround, // Distribusi ruang
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DamageLossLineChartCard extends StatelessWidget {
  final int limit;
  const DamageLossLineChartCard({Key? key, this.limit = 311}) : super(key: key);

  // Format angka ke dalam format Rupiah
  String _formatRupiah(double value) {
    if (value >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(1)}T';
    } else if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)}M';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}Jt';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}Rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final service = DisasterService();
    return FutureBuilder<List<DisasterDamage>>(
      future: service.fetchDisasterDamages(limit: limit),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return StyledCard(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.white)));
        }
        final data = snap.data;
        if (data == null || data.isEmpty) {
          return const StyledCard(child: Text('No data available', style: TextStyle(color: Colors.white)));
        }

        final totalDamage = <int, double>{};
        final totalLoss = <int, double>{};
        for (var d in data) {
          final year = int.tryParse(d.occurrenceYear) ?? 0;
          totalDamage[year] = (totalDamage[year] ?? 0) + d.damageValue;
          totalLoss[year] = (totalLoss[year] ?? 0) + d.lossValue;
        }

        final years = totalDamage.keys.toSet().union(totalLoss.keys.toSet()).toList()..sort();
        final spotsDamage = <FlSpot>[];
        final spotsLoss = <FlSpot>[];

        for (int i = 0; i < years.length; i++) {
          spotsDamage.add(FlSpot(i.toDouble(), totalDamage[years[i]] ?? 0));
          spotsLoss.add(FlSpot(i.toDouble(), totalLoss[years[i]] ?? 0));
        }

        return StyledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kerusakan & Kerugian per Tahun (dalam Rupiah)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  LegendItem(color: Colors.tealAccent, text: 'Kerusakan'),
                  SizedBox(width: 16),
                  LegendItem(color: Colors.redAccent, text: 'Kerugian'),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: years.length * 60.0, // Lebar per tahun ditambah
                  height: 220, // Tinggi ditambah
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50, // Ruang lebih untuk label Rupiah
                            getTitlesWidget: (v, _) => Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                'Rp${_formatRupiah(v)}',
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24, // Ruang untuk tahun
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= years.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  years[idx].toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      minX: 0,
                      maxX: (years.length - 1).toDouble(),
                      minY: 0,
                      maxY: [
                        totalDamage.values.fold(0.0, (p, n) => p > n ? p : n),
                        totalLoss.values.fold(0.0, (p, n) => p > n ? p : n),
                      ].reduce((a, b) => a > b ? a : b) * 1.2,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spotsDamage,
                          isCurved: true,
                          color: Colors.tealAccent,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.tealAccent.withOpacity(0.2)),
                        ),
                        LineChartBarData(
                          spots: spotsLoss,
                          isCurved: true,
                          color: Colors.redAccent,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Keterangan: T = Triliun, M = Miliar, Jt = Juta, Rb = Ribu',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const LegendItem({Key? key, required this.color, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}
