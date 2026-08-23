import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherTable extends StatelessWidget {
  final List<CityWeather> cityStates;
  final void Function(WeatherData) onCityTap;
  final void Function(int) onRetry;

  const WeatherTable({
    super.key,
    required this.cityStates,
    required this.onCityTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loadedCount = cityStates
        .where((c) => c.status == CityStatus.success)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Résultats',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$loadedCount/${cityStates.length} villes',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...cityStates.asMap().entries.map((entry) {
          final i = entry.key;
          final city = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CityCard(
              city: city,
              index: i,
              onTap: city.status == CityStatus.success && city.data != null
                  ? () => onCityTap(city.data!)
                  : null,
              onRetry: city.status == CityStatus.error
                  ? () => onRetry(i)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final CityWeather city;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  const _CityCard({
    required this.city,
    required this.index,
    this.onTap,
    this.onRetry,
  });

  List<Color> get _gradientColors {
    switch (index) {
      case 0:
        return [const Color(0xFF007AFF), const Color(0xFF0055CC)];
      case 1:
        return [const Color(0xFF5856D6), const Color(0xFF4240B0)];
      case 2:
        return [const Color(0xFFAF52DE), const Color(0xFF8944B0)];
      case 3:
        return [const Color(0xFFFF9500), const Color(0xFFCC7700)];
      case 4:
        return [const Color(0xFFFF3B30), const Color(0xFFCC2F26)];
      default:
        return [const Color(0xFF007AFF), const Color(0xFF0055CC)];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (city.status == CityStatus.loading) {
      return _LoadingCard(cityName: city.name, colors: _gradientColors);
    }
    if (city.status == CityStatus.error) {
      return _ErrorCard(
        cityName: city.name,
        message: city.errorMessage ?? 'Erreur inconnue',
        colors: _gradientColors,
        onRetry: onRetry,
      );
    }
    return _SuccessCard(
      weather: city.data!,
      colors: _gradientColors,
      onTap: onTap!,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String cityName;
  final List<Color> colors;

  const _LoadingCard({required this.cityName, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withAlpha(50),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            cityName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String cityName;
  final String message;
  final List<Color> colors;
  final VoidCallback? onRetry;

  const _ErrorCard({
    required this.cityName,
    required this.message,
    required this.colors,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cityName,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFAEAEB2),
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Réessayer',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withAlpha(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final WeatherData weather;
  final List<Color> colors;
  final VoidCallback onTap;

  const _SuccessCard({
    required this.weather,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withAlpha(50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.cityName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.description.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      weather.iconUrl,
                      width: 44,
                      height: 44,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.cloud_rounded,
                        size: 36,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.temperature.toInt()}°',
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _chip(Icons.water_drop_rounded, '${weather.humidity}%'),
                  const SizedBox(width: 16),
                  _chip(Icons.air_rounded, '${weather.windSpeed} m/s'),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withAlpha(150),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
