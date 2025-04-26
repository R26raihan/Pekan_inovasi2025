# Peduli Lindungi

Aplikasi peringatan bencana berbasis Flutter.

## Deskripsi

**Peduli Lindungi** adalah aplikasi mobile untuk peringatan dan informasi bencana menggunakan data resmi dari **BMKG** dan **BNPB**.  
Aplikasi ini menyediakan berbagai fitur yang membantu pengguna memantau kondisi cuaca, melihat statistik bencana, serta melakukan pelaporan kejadian bencana secara langsung.

## Fitur Utama

- **Informasi Cuaca**
  - Polusi udara
  - Kelembapan
  - Suhu
  - Data cuaca lainnya
- **Statistik Bencana**
  - Menampilkan data korban dan statistik tahunan kejadian bencana.
- **Map Interaktif**
  - Layer-layer cuaca real-time
  - Titik koordinat kejadian gempa dan bencana
- **Pelaporan Bencana**
  - User dapat mengirimkan laporan bencana melalui aplikasi.

## Fitur Relasi Kerabat Bencana (Sedang Dikembangkan)

- Membuat relasi dengan kerabat lain di dalam aplikasi.
- Saat kerabat atau user masuk ke dalam radius bencana:
  - Sistem otomatis mengirimkan notifikasi ke kerabat terkait.
  - Status kerabat di halaman relasi berubah menjadi "dalam radius bencana".
- Kerabat dapat mengubah status menjadi aman dengan menekan tombol **"Safe"**.
- Kerabat di luar radius akan mendapatkan **rute tercepat** menuju lokasi kerabat terdampak, menggunakan **Open Source Routing Machine (OSRM)**.

## Teknologi

- **Flutter** — Untuk pengembangan aplikasi mobile.
- **Firestore** — Sebagai database realtime.
- **Open Source Routing Machine (OSRM)** — Untuk fitur navigasi dan routing.

## Fitur yang Sedang Dipertimbangkan

- **Chatbot**  
  Untuk membantu interaksi pengguna dengan sistem secara otomatis.
- **Simulasi Bencana Berbasis Augmented Reality (AR)**  
  Memberikan pengalaman edukasi melalui teknologi AR tentang skenario bencana.


