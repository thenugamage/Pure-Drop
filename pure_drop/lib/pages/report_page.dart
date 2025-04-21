import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/navigationbar.dart';
import 'average.dart';
import 'home_page.dart';
import 'monthly.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'weekly.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentIndex = 1;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  DateTime selectedDate = DateTime.now();
  late DateTime weekStart;

  @override
  void initState() {
    super.initState();
    weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      _refreshReportPage();
    } else {
      _navigateToPage(index);
    }
  }

  void _refreshReportPage() {
    setState(() {});
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  void _previousWeek() {
    setState(() {
      weekStart = weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      weekStart = weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

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
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connected Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.circle, color: Colors.green, size: 10),
                            SizedBox(width: 6),
                            Text(
                              'Connected',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'last sync : 2 min ago',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 30),

                // Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tabItem(
                      icon: Icons.history,
                      label: 'History',
                      selected: true,
                    ),
                  ],
                ),

                // Calendar Card
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(weekStart),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: const [
                              Text(
                                "History",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            onPressed: _previousWeek,
                          ),
                          ...List.generate(7, (index) {
                            DateTime day = weekStart.add(Duration(days: index));
                            bool isSelected = DateUtils.isSameDay(
                              day,
                              selectedDate,
                            );
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = day;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      days[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isSelected
                                                ? Colors.pink.shade100
                                                : Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        "${day.day}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onPressed: _nextWeek,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Text(
                  "Drink Water Report",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                // Animated Report Buttons with Navigation
                _animatedReportButton(
                  title: "Weekly Report",
                  dotColor: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeeklyReportPage(),
                      ),
                    );
                  },
                ),
                _animatedReportButton(
                  title: "Monthly Report",
                  dotColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyReportPage(),
                      ),
                    );
                  },
                ),
                _animatedReportButton(
                  title: "Average Report",
                  dotColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AverageReportPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required IconData icon,
    required String label,
    bool selected = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 4),
        if (selected)
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }

  Widget _animatedReportButton({
    required String title,
    required Color dotColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: dotColor, size: 10),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
