package ru.foxstudios.digital_building_journal.di

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import ru.foxstudios.authlib.auth.AuthProvider
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.dependency_container.IContainer

const val IHTTPClientDIToken = "IHTTPClientDIToken"
const val I_SSO_DI_TOKEN = "I_SSO_DI_TOKEN"

val httpClient = HttpClient(){
    install(ContentNegotiation) {
        json()
    }
}

// BuildPlatformSpecificDependencies + shared dependencies
fun normalBuilder(builder : DependencyBuilder) : IContainer {
    builder.registryDependency(IHTTPClientDIToken, httpClient)
    builder.registryDependency(IAuthProviderDIToken, AuthProvider(builder.getDependency<HttpClient>(IHTTPClientDIToken), builder.getDependency<String>(I_SSO_DI_TOKEN)))
    return builder.build()
}