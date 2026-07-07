# 🏠 RUMA Tenant App - Aplikasi Penghuni Kos (Anak Kos)

Aplikasi mobile berbasis Flutter yang dirancang khusus untuk Penghuni Kos (Tenant/Anak Kos) guna mempermudah akses informasi kamar sewa, pemantauan riwayat tagihan bulanan, pembayaran sewa instan terintegrasi gateway pembayaran Midtrans, pelaporan keluhan fasilitas, dan penerimaan pengumuman penting dari pemilik kos.

---

## 🚀 Fitur Utama

1.  **Dashboard Ringkasan Kamar**: Menampilkan informasi sewa aktif, detail nomor kamar, alamat properti kos, tarif bulanan, dan status tagihan bulan berjalan (lunas / belum lunas).
2.  **Pembayaran Tagihan Terintegrasi (Midtrans Snap)**:
    *   Menginisiasi pembayaran tagihan dari aplikasi secara instan.
    *   Membuka antarmuka pembayaran Midtrans Snap menggunakan **WebView** terintegrasi di dalam aplikasi.
    *   Mendukung metode pembayaran transfer bank virtual account (VA), e-wallet (GoPay, ShopeePay), kartu kredit, atau QRIS.
3.  **Bayar Bulan Depan (Pay Next Month)**: Fitur pembayaran di muka (advance payment) sewa kamar untuk bulan berikutnya jika tagihan bulan berjalan telah lunas.
4.  **Pelaporan Keluhan (Complaints)**:
    *   Membuat laporan pengaduan jika terjadi kerusakan fasilitas kos (misal: pipa bocor, stopkontak mati, AC kurang dingin).
    *   Menginput deskripsi masalah dan melampirkan foto bukti kondisi kerusakan.
    *   Memantau pembaruan status perbaikan secara langsung dari dashboard (`pending` -> `in_progress` -> `resolved`).
5.  **Pengumuman Terintegrasi**: Mengakses secara langsung pengumuman mendesak dari pemilik kos (seperti pemeliharaan listrik, pemadaman air sementara, atau informasi gotong royong) dalam bentuk banner slider dinamis.
6.  **Riwayat Transaksi**: Menyimpan dokumentasi arsip seluruh bukti pembayaran bulanan terdahulu.

---

## 🛠️ Tech Stack & Dependensi

*   **Framework**: Flutter SDK (Dart)
*   **State Management**: Provider Pattern (`TenantProvider`, `AuthProvider`, `ComplaintProvider`)
*   **Networking**: Dio HTTP Client dengan Interceptor untuk header `Authorization: Bearer <token>`
*   **Secure Storage**: Flutter Secure Storage (untuk token JWT)
*   **Webview**: WebView Flutter (untuk menampilkan portal pembayaran Midtrans Snap secara langsung di dalam aplikasi)

---

## 📂 Struktur Folder Proyek

```text
rumatenant/
├── assets/                     # Gambar kos, logo ruma, dan ikon visual
├── lib/
│   ├── core/                   # Tema visual (Warna utama: Olive Green) & konfigurasi API Client Dio
│   ├── data/                   # Data konfigurasi lokal
│   ├── models/                 # Model objek Dart (User, Room, Tenant, Payment, Announcement, dll)
│   ├── providers/              # State Management (Auth, Tenant/Payments, Complaints)
│   ├── screens/                # Antarmuka Halaman (Home, Info Kamar, Pengaduan, WebView Midtrans)
│   └── widgets/                # Komponen UI reusable (cards, status badge, list items)
├── pubspec.yaml                # Konfigurasi dependensi package Flutter
└── README.md                   # Dokumentasi Aplikasi Tenant ini
```

---

## 🔄 Alur Kerja Spesifik Tenant (Flows)

### 1. Pembayaran Tagihan Sewa via Midtrans WebView
1.  Tenant membuka halaman **Pembayaran** (Payment Screen).
2.  Tenant memilih tagihan berstatus **Pending** -> klik **Bayar Sekarang**.
3.  Aplikasi mengirim request token pembayaran ke `/api/payments/:id/snap-token`.
4.  Backend merespons dengan mengembalikan **Snap Token** dan **Redirect URL** Midtrans Sandbox.
5.  Aplikasi membuka halaman `MidtransWebViewScreen` yang memuat portal pembayaran Midtrans Snap.
6.  Setelah tenant menyelesaikan transfer dana, status transaksi diverifikasi secara otomatis oleh sistem (melalui webhook Midtrans ke backend atau sinkronisasi realtime saat halaman di-refresh).
7.  Tagihan berubah status menjadi **Paid** (Lunas) di aplikasi tenant.

### 2. Logika Pengajuan Keluhan Kamar
1.  Tenant masuk ke menu **Pengaduan** -> klik **Buat Pengaduan**.
2.  Tenant mengisi judul keluhan, detail kronologi masalah, kategori, serta memasukkan foto bukti kerusakan.
3.  Setelah dikirim (`POST /api/complaints`), keluhan tersimpan di database dengan status awal **Pending**.
4.  Tenant dapat memantau pergerakan status pengerjaan yang diubah oleh owner. Ketika status berubah menjadi **In Progress** atau **Resolved**, tenant dapat melihat perubahan tersebut di daftar riwayat keluhan.

---

## ⚙️ Cara Menjalankan Aplikasi

Pastikan perangkat Android/iOS Emulator atau HP Fisik Anda telah terhubung (`flutter devices`).

1.  Jalankan instalasi package dependensi:
    ```bash
    flutter pub get
    ```
2.  Jalankan aplikasi dengan konfigurasi alamat IP Backend API (melalui variabel global):
    ```bash
    flutter run --dart-define="RUMA_API_BASE_URL=http://<IP_KOMPUTER_ANDA>:8080/api"
    ```
    *Atau jika menggunakan script otomatisasi di root direktori:*
    ```bash
    ../../start.sh tenant
    ```

---

## 🌐 Endpoint API yang Digunakan Tenant

Berikut adalah REST API utama yang diakses oleh RUMA Tenant App:

| HTTP Method | Endpoint | Kegunaan |
| :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Login akun penghuni kos |
| `GET` | `/api/auth/me` | Mengambil profil detail tenant saat ini |
| `GET` | `/api/tenants` | Mengambil data penempatan kamar & tanggal check-in |
| `GET` | `/api/boarding-houses` | Mengambil profil detail kos yang dihuni |
| `GET` | `/api/payments` | Mengambil riwayat tagihan pribadi tenant |
| `POST` | `/api/payments/:id/snap-token` | Meminta token pembayaran Midtrans Snap untuk tagihan |
| `GET` | `/api/payments/status/:orderId` | Memeriksa status transaksi terbaru di Midtrans |
| `POST` | `/api/payments/pay-next-month` | Membuat tagihan sewa di muka untuk bulan depan |
| `GET` | `/api/announcements` | Mengambil daftar pengumuman dari pemilik kos |
| `POST` | `/api/complaints` | Mengirim pengaduan keluhan fasilitas baru |
| `GET` | `/api/complaints` | Memantau riwayat status pengaduan pribadi |
