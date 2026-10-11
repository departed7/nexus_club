import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/role.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kRole = 'auth_user_role';
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';

  final SharedPreferences _prefs;
  final Dio _dio;

  AppUser? _user;
  String? _accessToken;
  bool _isInitialized = false;

  AuthNotifier(this._prefs, this._dio);

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  // Проверка прав по иерархии уровней
  bool has(Role role) => _user != null && _user!.role.level >= role.level;

  Future<void> restore() async {
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);

    if (access != null) {
      _accessToken = access;
      final cachedRole = _prefs.getString(_kRole);
    if (cachedRole != null) {
        _user = AppUser(id: 3, username: 'gamer', email: 'gamer@nexus.club', role: Role.fromString(cachedRole));
      }
      try {
        final res = await _dio.get(
          '/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $access'}),
        );
        _user = AppUser.fromJson(res.data as Map<String, dynamic>);
      } catch (_) {
        if (refresh != null) {
          await refreshTokens();
        } else {
          await logout();
        }
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    _accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    await _prefs.setString(_kAccess, _accessToken!);
    await _prefs.setString(_kRole, _user!.role.name);
    await _prefs.setString(_kRefresh, refreshToken);
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    final res = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    _accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    await _prefs.setString(_kAccess, _accessToken!);
    await _prefs.setString(_kRefresh, refreshToken);
    notifyListeners();
  }

  Future<bool> refreshTokens() async {
    final refresh = _prefs.getString(_kRefresh);
    if (refresh == null) {
      await logout();
      return false;
    }
    try {
      final res = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = res.data as Map<String, dynamic>;
      _accessToken = data['accessToken'] as String;
      final newRefresh = data['refreshToken'] as String;

      await _prefs.setString(_kAccess, _accessToken!);
      await _prefs.setString(_kRefresh, newRefresh);

      final meRes = await _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );
      _user = AppUser.fromJson(meRes.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    notifyListeners();
  }
}