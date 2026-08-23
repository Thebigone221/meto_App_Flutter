import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../models/weather_model.dart';
import '../widgets/weather_gauge.dart';
import '../widgets/weather_table.dart';
import 'detail_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _noticeController;

  @override
  void initState() {
    super.initState();
    _noticeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().startLoading();
    });
  }

  @override
  void dispose() {
    _noticeController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<WeatherProvider>().retry();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF10102A), const Color(0xFF080818)]
                : [const Color(0xFF87CEEB), const Color(0xFFB8E4F0), const Color(0xFFF2F2F7)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, themeProvider),
              Expanded(
                child: Consumer<WeatherProvider>(
                  builder: (context, provider, _) {
                    final allEmpty = provider.cityStates.isEmpty && !provider.isLoading;

                    if (allEmpty && provider.isComplete) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: const Color(0xFF007AFF),
                        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        child: ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Column(
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 48,
                                  color: isDark ? Colors.white38 : Colors.black26,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune donnée disponible',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tirez vers le bas pour réessayer',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF007AFF),
                      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      displacement: 40,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            WeatherGauge(
                              progress: provider.progress,
                              isComplete: provider.isComplete,
                            ),
                            const SizedBox(height: 16),
                            if (!provider.isComplete) ...[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  provider.currentMessage,
                                  key: ValueKey(provider.currentMessage),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: const Color(0xFF8E8E93),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (provider.isLoading)
                                Text(
                                  '${provider.loadedCount}/${WeatherProvider.cities.length} villes',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF007AFF),
                                  ),
                                ),
                            ],
                            const SizedBox(height: 24),
                            if (provider.isComplete)
                              _buildRefreshNotice(context, isDark),
                            const SizedBox(height: 16),
                            if (provider.cityStates.isNotEmpty)
                              AnimatedOpacity(
                                opacity: provider.cityStates.isEmpty ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                child: WeatherTable(
                                  cityStates: provider.cityStates,
                                  onCityTap: (WeatherData city) {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 500),
                                        reverseTransitionDuration: const Duration(milliseconds: 300),
                                        pageBuilder: (ctx, anim, sec) => DetailScreen(weather: city),
                                        transitionsBuilder: (ctx, animation, sec, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.05),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            )),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  onRetry: (int index) => provider.retryCity(index),
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshNotice(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: _noticeController,
      child: GestureDetector(
        onTap: _onRefresh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withAlpha(8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF8E8E93),
              ),
              const SizedBox(width: 8),
              Text(
                'Tirez vers le bas ou cliquez pour actualiser',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          Expanded(
            child: Text(
              'Météo en Direct',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}
