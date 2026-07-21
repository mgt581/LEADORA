import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'app_sidebar.dart';
import 'app_top_bar.dart';

class AppShell extends StatelessWidget {
  final String currentRoute;
  final String pageTitle;
  final String? pageSubtitle;
  final Widget body;
  final List<Widget>? topBarActions;

  const AppShell({
    super.key,
    required this.currentRoute,
    required this.pageTitle,
    this.pageSubtitle,
    required this.body,
    this.topBarActions,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;

    if (isNarrow) {
      return _MobileShell(
        currentRoute: currentRoute,
        pageTitle: pageTitle,
        pageSubtitle: pageSubtitle,
        topBarActions: topBarActions,
        body: body,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                AppTopBar(
                  title: pageTitle,
                  subtitle: pageSubtitle,
                  actions: topBarActions,
                ),
                Expanded(
                  child: Container(
                    color: AppColors.contentBg,
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileShell extends StatefulWidget {
  final String currentRoute;
  final String pageTitle;
  final String? pageSubtitle;
  final Widget body;
  final List<Widget>? topBarActions;

  const _MobileShell({
    required this.currentRoute,
    required this.pageTitle,
    this.pageSubtitle,
    required this.body,
    this.topBarActions,
  });

  @override
  State<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<_MobileShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSpacing.topbarHeight),
        child: AppTopBar(
          title: widget.pageTitle,
          subtitle: widget.pageSubtitle,
          actions: widget.topBarActions,
        ),
      ),
      drawer: AppSidebar(currentRoute: widget.currentRoute),
      body: Container(
        color: AppColors.contentBg,
        child: widget.body,
      ),
    );
  }
}
