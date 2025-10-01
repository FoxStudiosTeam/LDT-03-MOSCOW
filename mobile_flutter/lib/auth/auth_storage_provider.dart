import 'package:shared_preferences/shared_preferences.dart';

// IAuthStorageProvider
abstract class IAuthStorageProvider {
  Future<String> getRefreshToken();
  Future<String> getAccessToken();

  Future<void> clear();
  Future<void> saveRefreshToken(String refreshToken, int exp, int currentTime);
  Future<void> saveAccessToken(String accessToken, int exp);
  Future<int> getRefreshTokenTTL();
  Future<int> getAccessTokenTTL();
  Future<int> getRefreshTokenTTLStart();
  Future<void> saveRole(String role);
  Future<String> getRole();
}

const IAuthStorageProviderDIToken = "I-Auth-Storage-Provider-DI-Token";

// AuthProvider - default implementation for IAuthStorageProvider
class AuthStorageProvider implements IAuthStorageProvider {
  String ROLE_KEY = "role-key";

  String REFRESH_TOKEN_KEY = "refresh-token-key";
  String REFRESH_TOKEN_TTL_KEY = "refresh-token-ttl-key";
  String REFRESH_TOKEN_TTL_START_KEY = "refresh-token-ttl-start-key";

  String ACCESS_TOKEN_KEY = "access-token-key";
  String ACCESS_TOKEN_TTL_KEY = "access-token-ttl-key";

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async{
    if (prefs == null) {
      await init();
    }
    await prefs?.remove(REFRESH_TOKEN_KEY);
    await prefs?.remove(REFRESH_TOKEN_TTL_KEY);
    await prefs?.remove(REFRESH_TOKEN_TTL_START_KEY);
    await prefs?.remove(ACCESS_TOKEN_KEY);
    await prefs?.remove(ACCESS_TOKEN_TTL_KEY);
    await prefs?.remove(ROLE_KEY);
  }

  @override
  Future<String> getRole() async {
    if (prefs == null) {
      await init();
    }

    String? role = prefs?.getString(ROLE_KEY);
    return role ?? "";
  }

  @override
  Future<String> getAccessToken() async{
    if (prefs == null) {
      await init();
    }
    String? accessToken = prefs?.getString(ACCESS_TOKEN_KEY);
    if (accessToken != null) {
      return accessToken;
    }
    return "";
  }

  @override
  Future<int> getAccessTokenTTL() async{
    if (prefs == null) {
      await init();
    }
    int? ttl = prefs?.getInt(ACCESS_TOKEN_TTL_KEY);
    if (ttl != null) {
      return ttl;
    }
    return 0;
  }

  @override
  Future<String> getRefreshToken() async {
    if (prefs == null) {
      await init();
    }
    String? refresh = prefs?.getString(REFRESH_TOKEN_KEY);
    if (refresh != null) {
      return refresh;
    }
    return "";
  }

  @override
  Future<int> getRefreshTokenTTL() async{
    if (prefs == null) {
      await init();
    }
    int? ttl = prefs?.getInt(REFRESH_TOKEN_TTL_KEY);
    if (ttl != null) {
      return ttl;
    }
    return 0;
  }

  @override
  Future<int> getRefreshTokenTTLStart() async {
    if (prefs == null) {
      await init();
    }
    int? ttlStart = prefs?.getInt(REFRESH_TOKEN_TTL_START_KEY);
    if (ttlStart != null) {
      return ttlStart;
    }
    return 0;
  }

  @override
  Future<void> saveAccessToken(String accessToken, int exp) async{
    if (prefs == null) {
      await init();
    }

    await prefs?.setString(ACCESS_TOKEN_KEY, accessToken);
    await prefs?.setInt(ACCESS_TOKEN_TTL_KEY, exp);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken, int exp, int currentTime) async {
    if (prefs == null) {
      await init();
    }

    await prefs?.setString(REFRESH_TOKEN_KEY, refreshToken);
    await prefs?.setInt(REFRESH_TOKEN_TTL_KEY, exp);
    await prefs?.setInt(REFRESH_TOKEN_TTL_START_KEY, currentTime);
  }

  @override
  Future<void> saveRole(String role) async {
    if (prefs == null) {
      await init();
    }

    await prefs?.setString(ROLE_KEY, role);
  }
  
}