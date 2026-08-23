import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeatherData {
  final String cityName;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final double latitude;
  final double longitude;
  final String description;
  final String icon;

  const WeatherData({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] as String? ?? '',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['coord']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['coord']?['lon'] as num?)?.toDouble() ?? 0.0,
      description: (json['weather'] as List?)?.isNotEmpty == true
          ? (json['weather'][0]['description'] as String? ?? '')
          : '',
      icon: (json['weather'] as List?)?.isNotEmpty == true
          ? (json['weather'][0]['icon'] as String? ?? '01d')
          : '01d',
    );
  }

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
