package ru.foxstudios.digital_building_journal.dummy

import ru.foxstudios.authlib.auth.IAuthStorageProvider

class DummyAuthStorageProvider : IAuthStorageProvider {

    private var dummyRefreshToken: String = "dummy"
    private var dummyRefreshTokenTTL: Long = 0
    private var dummyRefreshTokenStart: Long = 0

    private var dummyAccessToken: String = "dummy"
    private var dummyAccessTokenTTL: Long = 0

    override fun getRefreshToken(): String {
        return dummyRefreshToken
    }

    override fun saveRefreshToken(refreshToken: String, exp: Long, currentTime: Long): Result<Unit> {
        dummyRefreshToken = refreshToken
        dummyRefreshTokenTTL = exp
        dummyRefreshTokenStart = currentTime
        return Result.success(Unit)
    }

    override fun clear(): Result<Unit> {
        dummyRefreshToken = "dummy"
        dummyRefreshTokenTTL = 0
        dummyRefreshTokenStart = 0
        dummyAccessToken = "dummy"
        dummyAccessTokenTTL = 0
        return Result.success(Unit)
    }

    override fun getRefreshTokenTTL(): Long {
        return dummyRefreshTokenTTL
    }

    override fun getAccessToken(): String {
        return dummyAccessToken
    }

    override fun saveAccessToken(accessToken: String, exp: Long): Result<Unit> {
        dummyAccessToken = accessToken
        dummyAccessTokenTTL = exp
        return Result.success(Unit)
    }

    override fun getAccessTokenTTL(): Long {
        return dummyAccessTokenTTL
    }
}
