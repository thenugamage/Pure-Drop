// home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/navigationbar.dart';
import 'report_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      // Refresh button tapped
      _refreshHomePage();
    } else {
      _navigateToPage(index);
    }
  }

  void _refreshHomePage() {
    setState(() {
      // This will rebuild the HomePage. In a real app, you might want to
      // re-fetch data or reset some state here.
    });
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1: // Analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportPage()),
        );
        break;
      case 3: // Setting
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
        break;
      case 4: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
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
        navigatorKey: _navigatorKey,
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.info_outline, color: Colors.indigo[900]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: "pH Level",
                          value: "7.20",
                          subtitle: "Range:6.5–8.5",
                          icon: Icons.water_drop,
                          status: "Normal",
                          statusColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: "Temperature",
                          value: "23.50 C",
                          subtitle: "74.30 F",
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
                          value: "5.80 NTU",
                          subtitle: "Threshold: 5.0 NTU",
                          icon: Icons.blur_on,
                          status: "Warning",
                          statusColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: "Quality Type",
                          value: "",
                          subtitle: "",
                          icon: null,
                          status: "Normal",
                          statusColor: Colors.green,
                          showValue: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 248, 225, 1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.amber),
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
                              Text(
                                "Turbidity levels are above normal theshold. Consider maintenance check.",
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.black54)),
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
                    color: statusColor == Colors.orange
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                const Spacer(),
                if (icon != null)
                  Icon(
                    icon,
                    color: Colors.black,
                    size: 24,
                  ),
              ],
            ),
            Text(
              subtitle,
              style:
                  GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
            ),
          ] else
            const SizedBox(height: 24),
        ],
      ),
    );
  }
}