import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<FlSpot> phSpots = [];
  double avgPh = 0, avgTemp = 0, avgTurbidity = 0;
  bool isLoading = true;
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    _stream = FirebaseFirestore.instance
        .collection('water_logs')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(oneMonthAgo))
        .orderBy('timestamp')
        .snapshots();

    _stream.listen((snapshot) {
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      double phSum = 0, tempSum = 0, turbiditySum = 0;
      List<FlSpot> tempSpots = [];

      for (int i = 0; i < docs.length; i++) {
        final data = docs[i].data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final day = timestamp.day.toDouble();

        double? ph = (data['pH'] as num?)?.toDouble();
        double? temp = (data['temperature'] as num?)?.toDouble();
        double? turbidity = (data['turbidity'] as num?)?.toDouble();

        if (ph != null && temp != null && turbidity != null) {
          phSum += ph;
          tempSum += temp;
          turbiditySum += turbidity;
          tempSpots.add(FlSpot(day, ph));
        }
      }

      setState(() {
        avgPh = phSum / docs.length;
        avgTemp = tempSum / docs.length;
        avgTurbidity = turbiditySum / docs.length;
        phSpots = tempSpots;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Monthly Report",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(53, 114, 239, 0.8),
                  Color.fromRGBO(56, 152, 244, 0.7),
                  Color.fromRGBO(58, 190, 249, 0.6),
                  Color.fromRGBO(167, 230, 255, 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Water Quality Overview",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _dataCard("Avg pH Level", avgPh.toStringAsFixed(2), "Safe Range: 6.5 - 8.5", Icons.water_drop),
                _dataCard("Avg Temperature", "${avgTemp.toStringAsFixed(1)} °C", "Normal range: 10 - 50 °C", Icons.thermostat),
                _dataCard("Avg Turbidity", "${avgTurbidity.toStringAsFixed(1)} NTU", "Safe below 5.0 NTU", Icons.opacity),
                const SizedBox(height: 24),
                _buildAnalysisChart(),
                const Spacer(),
                Center(
                  child: Text(
                    "Data generated from daily water logs.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              Text(subtitle, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_chartLabel("TIME"), _chartLabel("PH")],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (value) =>
                      FlLine(color: Colors.pink.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if ([
                          1,
                          5,
                          10,
                          15,
                          20,
                          25,
                          30,
                        ].contains(value.toInt())) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "${value.toInt()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: false,
                    color: Colors.black,
                    dotData: FlDotData(show: false),
                    spots: [
                      FlSpot(1, 60),
                      FlSpot(5, 120),
                      FlSpot(10, 30),
                      FlSpot(15, 180),
                      FlSpot(20, 0),
                      FlSpot(25, 180),
                      FlSpot(30, 120),
                    ],
                  ),
                ],
                minY: 0,
                maxY: 240,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
