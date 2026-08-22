import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_spacing.dart';
import 'app_sidebar.dart';
import 'app_top_bar.dart';

/// Production-grade responsive application shell for Dayflow.
/// Supports Desktop, Tablet, and Mobile layouts.
class AppShell extends StatefulWidget {
  final Widget child;
  final String location;

  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getPageTitle(String location) {
    if (location.startsWith('/employees')) return 'Employees';
    if (location.startsWith('/attendance')) return 'Attendance';
    if (location.startsWith('/leave')) return 'Leave Management';
    if (location.startsWith('/payroll')) return 'Payroll';
    if (location.startsWith('/documents')) return 'Documents';
    if (location.startsWith('/reports')) return 'Reports';
    if (location.startsWith('/analytics')) return 'Analytics';
    if (location.startsWith('/notifications')) return 'Notifications';
    if (location.startsWith('/settings')) return 'Settings';
    if (location.startsWith('/design-system')) return 'Design System Preview';
    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final title = _getPageTitle(widget.location);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          title: title,
          showMenuButton: true,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: Drawer(
          child: AppSidebar(
            isCollapsed: false,
            onToggleCollapse: () {},
            currentRoute: widget.location,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: widget.child,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomNavIndex(widget.location),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/employees');
                break;
              case 2:
                context.go('/attendance');
                break;
              case 3:
                context.go('/leave');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Employees'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time_outlined), label: 'Attendance'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Leave'),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: isTablet || _isSidebarCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
            currentRoute: widget.location,
          ),
          Expanded(
            child: Column(
              children: [
                AppTopBar(title: title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getBottomNavIndex(String location) {
    if (location.startsWith('/employees')) return 1;
    if (location.startsWith('/attendance')) return 2;
    if (location.startsWith('/leave')) return 3;
    return 0;
  }
}
