import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../models/weather_model.dart';

part 'weather_api.g.dart';

@RestApi(baseUrl: 'https://api.openweathermap.org/data/2.5/')
abstract class WeatherApi {
  factory WeatherApi(Dio dio, {String? baseUrl}) = _WeatherApi;

  @GET('weather')
  Future<WeatherData> getWeather(
    @Query('q') String city,
    @Query('appid') String apiKey,
    @Query('units') String units,
    @Query('lang') String lang,
  );
}
