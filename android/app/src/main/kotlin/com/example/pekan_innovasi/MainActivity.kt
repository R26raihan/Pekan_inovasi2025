package com.example.pekan_innovasi

import io.flutter.embedding.android.FlutterActivity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.content.Context

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        // Hanya diperlukan untuk Android API 26+ (Oreo)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "location_channel", // Sesuai dengan notificationChannelId di Dart
                "Location Tracking", // Nama channel yang terlihat di pengaturan
                NotificationManager.IMPORTANCE_LOW // Gunakan IMPORTANCE_LOW untuk menghindari suara notifikasi
            ).apply {
                description = "Channel untuk notifikasi pelacakan lokasi"
            }

            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}