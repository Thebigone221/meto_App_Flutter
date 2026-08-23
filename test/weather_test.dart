import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_app/models/weather_model.dart';
import 'package:meteo_app/providers/weather_provider.dart';
import 'package:meteo_app/services/weather_service.dart';

void main() {
  group('WeatherData.fromJson', () {
    test('parses valid OpenWeather JSON', () {
      final json = {
        'name': 'Dakar',
        'main': {'temp': 28.5, 'humidity': 75},
        'wind': {'speed': 4.2},
        'coord': {'lat': 14.6928, 'lon': -17.4467},
        'weather': [
          {'description': 'ciel dégagé', 'icon': '01d'},
        ],
      };

      final data = WeatherData.fromJson(json);

      expect(data.cityName, 'Dakar');
      expect(data.temperature, 28.5);
      expect(data.humidity, 75);
      expect(data.windSpeed, 4.2);
      expect(data.latitude, closeTo(14.6928, 0.001));
      expect(data.longitude, closeTo(-17.4467, 0.001));
      expect(data.description, 'ciel dégagé');
      expect(data.icon, '01d');
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final data = WeatherData.fromJson(json);

      expect(data.cityName, '');
      expect(data.temperature, 0.0);
      expect(data.humidity, 0);
      expect(data.windSpeed, 0.0);
      expect(data.latitude, 0.0);
      expect(data.longitude, 0.0);
      expect(data.description, '');
      expect(data.icon, '01d');
    });

    test('handles empty weather list', () {
      final json = {'name': 'Test', 'weather': <dynamic>[]};

      final data = WeatherData.fromJson(json);

      expect(data.cityName, 'Test');
      expect(data.description, '');
      expect(data.icon, '01d');
    });

    test('iconUrl builds correct URL', () {
      final data = WeatherData(
        cityName: 'Dakar',
        temperature: 25,
        humidity: 60,
        windSpeed: 3,
        latitude: 14.69,
        longitude: -17.45,
        description: 'clear',
        icon: '02d',
      );

      expect(data.iconUrl, 'https://openweathermap.org/img/wn/02d@2x.png');
    });
  });

  group('WeatherProvider', () {
    late WeatherProvider provider;

    setUp(() {
      final service = WeatherService(apiKey: 'test-key');
      provider = WeatherProvider(service);
    });

    test('initial state is empty', () {
      expect(provider.cityStates, isEmpty);
      expect(provider.isComplete, false);
      expect(provider.isLoading, false);
      expect(provider.progress, 0.0);
    });

    test('cities list has 5 cities', () {
      expect(WeatherProvider.cities.length, 5);
      expect(WeatherProvider.cities, contains('Dakar'));
      expect(WeatherProvider.cities, contains('Ziguinchor'));
    });

    test('loading messages are defined', () {
      expect(WeatherProvider.loadingMessages.length, greaterThanOrEqualTo(3));
    });

    test('progress calculates correctly', () {
      provider.startLoading();

      expect(provider.isLoading, true);
      expect(provider.progress, 0.0);
      expect(provider.cityStates.length, 5);

      provider.dispose();
    });

    test('restart clears state', () {
      provider.restart();
      expect(provider.cityStates, isEmpty);
      expect(provider.isComplete, false);
    });
  });
}
