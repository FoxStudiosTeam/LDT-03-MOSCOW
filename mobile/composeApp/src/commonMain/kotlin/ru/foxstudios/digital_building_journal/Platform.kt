package ru.foxstudios.digital_building_journal

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform