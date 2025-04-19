import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/navigationbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'waterQuality',
  );

  double? ph, temperature, turbidity;
  String clearness = "";

  @override
  void initState() {
    super.initState();
    _listenToWaterQualityUpdates();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _listenToWaterQualityUpdates() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        ph = (data['pH'] as num?)?.toDouble() ?? 0.0;
        temperature = (data['temperature'] as num?)?.toDouble() ?? 0.0;
        turbidity = (data['turbidity'] as num?)?.toDouble() ?? 0.0;
        clearness = data['clearness'] ?? "Unknown";
      });

      _storeToFirestore();
    });
  }

  void _storeToFirestore() async {
    await FirebaseFirestore.instance.collection('water_logs').add({
      'timestamp': Timestamp.now(),
      'pH': ph,
      'temperature': temperature,
      'turbidity': turbidity,
      'clearness': clearness,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.sync, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        navigatorKey: GlobalKey<NavigatorState>(),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(53, 114, 239, 0.8),
                  Color.fromRGBO(56, 152, 244, 0.7),
                  Color.fromRGBO(58, 190, 249, 0.6),
                  Color.fromRGBO(167, 230, 255, 0.5),
                ],
                stops: [0.25, 0.38, 0.50, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.mail_outline, color: Colors.indigo[900]),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: "pH Level",
                            value: ph?.toStringAsFixed(2) ?? '--',
                            subtitle: "Range: 6.5 - 8.5",
                            icon: Icons.water_drop,
                            status: _getPhStatus(),
                            statusColor: _getPhStatusColor(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: "Temperature",
                            value:
                                "${temperature?.toStringAsFixed(2) ?? '--'} °C",
                            subtitle: "Celsius",
                            icon: Icons.thermostat,
                            status: "Normal",
                            statusColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: "Turbidity",
                            value:
                                "${turbidity?.toStringAsFixed(2) ?? '--'} NTU",
                            subtitle: "Threshold: 5.0 NTU",
                            icon: Icons.opacity,
                            status: _getTurbidityStatus(),
                            statusColor: _getTurbidityStatusColor(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: "Quality Type",
                            value: clearness,
                            subtitle: "",
                            icon: null,
                            status: clearness,
                            statusColor:
                                clearness == "CLEAN WATER"
                                    ? Colors.green
                                    : Colors.red,
                            showValue: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 248, 225, 1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Water Quality Alert",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getAlertMessage(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _listenToWaterQualityUpdates(); // Refresh manually
                        },
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        label: Text(
                          "Refresh Data",
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Open a settings screen here
                        },
                        icon: const Icon(Icons.settings, color: Colors.blue),
                        label: Text(
                          "Configure",
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPhStatus() {
    if (ph == null) return "Unknown";
    if (ph! < 6.5 || ph! > 8.5) return "Abnormal";
    return "Normal";
  }

  Color _getPhStatusColor() {
    if (ph == null) return Colors.grey;
    return (ph! < 6.5 || ph! > 8.5) ? Colors.red : Colors.green;
  }

  String _getTurbidityStatus() {
    if (turbidity == null) return "Unknown";
    return turbidity! > 5.0 ? "Warning" : "Normal";
  }

  Color _getTurbidityStatusColor() {
    if (turbidity == null) return Colors.grey;
    return turbidity! > 5.0 ? Colors.orange : Colors.green;
  }

  String _getAlertMessage() {
    List<String> issues = [];

    if (turbidity != null && turbidity! > 5.0) {
      issues.add("• Turbidity is above the safe threshold (5.0 NTU)");
    }
    if (ph != null && (ph! < 6.5 || ph! > 8.5)) {
      issues.add("• pH level is outside the normal range (6.5 - 8.5)");
    }
    if (temperature != null && (temperature! < 10 || temperature! > 50)) {
      issues.add("• Temperature is outside the recommended range (10–50°C)");
    }

    return issues.isNotEmpty
        ? issues.join('\n')
        : "All water quality parameters are within safe limits.";
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData? icon,
    required String status,
    required Color statusColor,
    bool showValue = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showValue) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                if (icon != null) Icon(icon, color: Colors.blue, size: 24),
              ],
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
            ),
          ] else
            const SizedBox(height: 24),
        ],
      ),
    );
  }
}
