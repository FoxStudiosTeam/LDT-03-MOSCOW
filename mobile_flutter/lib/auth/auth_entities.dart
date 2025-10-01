class AccessTokenData {
  String accessTokenValue;
  int ext;

  AccessTokenData(this.accessTokenValue, this.ext);
}

class RefreshTokenData {
  String refreshTokenValue;
  int ext;
  int ttlStart;

  RefreshTokenData(this.refreshTokenValue, this.ext, this.ttlStart);
}