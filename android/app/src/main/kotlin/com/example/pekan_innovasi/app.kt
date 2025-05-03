package com.example.pekan_innovasi

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationManagerCompat

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "location_channel",
                "Pembaruan Lokasi",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Saluran untuk notifikasi layanan lokasi latar belakang"
            }
            val notificationManager = NotificationManagerCompat.from(this@App)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
