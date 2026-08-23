import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum CityStatus { loading, success, error }

class CityWeather {
  final String name;
  final CityStatus status;
  final WeatherData? data;
  final String? errorMessage;

  const CityWeather({
    required this.name,
    required this.status,
    this.data,
    this.errorMessage,
  });
}

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service;

  WeatherProvider(this._service);

  static const List<String> cities = [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Kaolack',
    'Ziguinchor',
  ];

  static const List<String> loadingMessages = [
    'Nous téléchargeons les données…',
    'C\'est presque fini…',
    'Plus que quelques secondes avant d\'avoir le résultat…',
    'Analyse des conditions météo…',
    'Dernière vérification…',
  ];

  List<CityWeather> _cityStates = [];
  bool _isComplete = false;
  bool _isLoading = false;
  int _messageIndex = 0;
  Timer? _messageTimer;
  Timer? _apiTimer;
  int _cityIndex = 0;

  List<CityWeather> get cityStates => _cityStates;
  bool get isComplete => _isComplete;
  bool get isLoading => _isLoading;
  String get currentMessage => loadingMessages[_messageIndex];

  double get progress {
    final loaded = _cityStates
        .where((c) => c.status != CityStatus.loading)
        .length;
    return loaded / cities.length;
  }

  int get loadedCount {
    return _cityStates.where((c) => c.status != CityStatus.loading).length;
  }

  void startLoading() {
    _reset();
    _isLoading = true;
    _cityStates = cities
        .map((c) => CityWeather(name: c, status: CityStatus.loading))
        .toList();
    notifyListeners();

    _messageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _messageIndex = (_messageIndex + 1) % loadingMessages.length;
      notifyListeners();
    });

    _apiTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchNextCity();
    });

    _fetchNextCity();
  }

  bool _fetching = false;

  Future<void> _fetchNextCity() async {
    if (_fetching || _cityIndex >= cities.length) {
      if (_cityIndex >= cities.length) _complete();
      return;
    }
    _fetching = true;

    final cityName = cities[_cityIndex];
    final index = _cityIndex;
    _cityIndex++;

    try {
      final weather = await _service.getWeather(cityName);
      _cityStates[index] = CityWeather(
        name: cityName,
        status: CityStatus.success,
        data: weather,
      );
    } catch (e) {
      _cityStates[index] = CityWeather(
        name: cityName,
        status: CityStatus.error,
        errorMessage: 'Impossible de charger les données',
      );
    }

    notifyListeners();
    _fetching = false;

    if (_cityIndex >= cities.length) {
      _complete();
    }
  }

  void retryCity(int index) async {
    final cityName = cities[index];
    _cityStates[index] = CityWeather(
      name: cityName,
      status: CityStatus.loading,
    );
    notifyListeners();

    try {
      final weather = await _service.getWeather(cityName);
      _cityStates[index] = CityWeather(
        name: cityName,
        status: CityStatus.success,
        data: weather,
      );
    } catch (e) {
      _cityStates[index] = CityWeather(
        name: cityName,
        status: CityStatus.error,
        errorMessage: 'Impossible de charger les données',
      );
    }

    notifyListeners();
  }

  void _complete() {
    _isComplete = true;
    _isLoading = false;
    _messageTimer?.cancel();
    _apiTimer?.cancel();
    notifyListeners();
  }

  void retry() {
    _reset();
    startLoading();
  }

  void restart() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _cityStates = [];
    _isComplete = false;
    _isLoading = false;
    _messageIndex = 0;
    _cityIndex = 0;
    _fetching = false;
    _messageTimer?.cancel();
    _apiTimer?.cancel();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _apiTimer?.cancel();
    super.dispose();
  }
}
