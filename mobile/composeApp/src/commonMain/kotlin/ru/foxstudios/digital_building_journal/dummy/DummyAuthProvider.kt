package ru.foxstudios.digital_building_journal.dummy

import ru.foxstudios.authlib.auth.IAuthProvider
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.entities.AccessTokenData

class DummyAuthProvider : IAuthProvider {

    override suspend fun login(
        login: String,
        password: String,
        timeOut: Long,
        authStorageProvider: IAuthStorageProvider
    ): Result<AccessTokenData> {
        val fakeToken = AccessTokenData(
            accessToken = "dummy_access_token",
            exp = 3600
        )
        return Result.success(fakeToken)
    }

    override suspend fun register(
        login: String,
        password: String,
        timeOut: Long,
        authStorageProvider: IAuthStorageProvider
    ): Result<AccessTokenData> {
        val fakeToken = AccessTokenData(
            accessToken = "dummy_access_token",
            exp = 3600
        )
        return Result.success(fakeToken)
    }

    override suspend fun refreshToken(
        refreshToken: String,
        timeOut: Long,
        authStorageProvider: IAuthStorageProvider
    ): Result<AccessTokenData> {
        val fakeToken = AccessTokenData(
            accessToken = "dummy_refreshed_access_token",
            exp = 3600
        )
        return Result.success(fakeToken)
    }

    override suspend fun logout(
        refreshToken: String,
        timeOut: Long,
        authStorageProvider: IAuthStorageProvider
    ): Result<Unit> {
        return Result.success(Unit)
    }
}