import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import 'weather_api.dart';

class WeatherService {
  late final WeatherApi _api;
  final String apiKey;

  WeatherService({required this.apiKey}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openweathermap.org/data/2.5/',
        queryParameters: {'appid': apiKey, 'units': 'metric', 'lang': 'fr'},
      ),
    );
    _api = WeatherApi(dio);
  }

  Future<WeatherData> getWeather(String city) async {
    return _api.getWeather(city, apiKey, 'metric', 'fr');
  }
}
