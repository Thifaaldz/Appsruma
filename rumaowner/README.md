# 🏠 RUMA Owner App - Sistem Pengelolaan Kos (Ibu Kos)

Aplikasi mobile berbasis Flutter yang dirancang khusus untuk Pemilik Kos (Owner/Ibu Kos) guna mempermudah pengelolaan properti, kamar, data penghuni (tenant), pencatatan pengeluaran, pemantauan pengaduan kerusakan, serta analisis laporan keuangan (laba rugi) secara real-time.

---

## 🚀 Fitur Utama

1.  **Dashboard Properti**: Pemantauan tingkat okupansi kamar (jumlah terisi, kosong, dalam perbaikan) secara visual.
2.  **Manajemen Kamar**: Menambah, mengubah detail, harga sewa, foto galeri, dan status ketersediaan kamar.
3.  **Manajemen Penghuni (Tenant)**:
    *   Mendaftarkan penghuni baru ke kamar yang tersedia.
    *   Menentukan siklus penagihan bulanan (`billing_day`).
    *   Proses check-out penghuni secara teratur.
4.  **Manajemen Keuangan & Laba Rugi**:
    *   **Pemasukan**: Rekapitulasi otomatis dari pembayaran sewa bulanan tenant yang berstatus *Paid* (lunas).
    *   **Pengeluaran**: Formulir pencatatan manual pengeluaran operasional kos (utilitas, internet, pemeliharaan, kebersihan).
    *   **Analisis Finansial**: Visualisasi grafik pendapatan vs pengeluaran bulanan beserta perhitungan laba bersih.
5.  **Konfirmasi Pembayaran**: Konfirmasi manual untuk transaksi yang dibayarkan di luar sistem Midtrans (seperti tunai atau transfer bank langsung).
6.  **Pusat Pengaduan Keluhan**: Meninjau keluhan fasilitas yang dikirim oleh tenant (disertai foto bukti) dan memperbarui status penanganannya (`pending` -> `in_progress` -> `resolved`).
7.  **Penyebaran Pengumuman**: Membuat pengumuman penting bagi seluruh penghuni kos dengan opsi ikon kategori (`water` / `electric` / `repair` / `info`).

---

## 🛠️ Tech Stack & Dependensi

*   **Framework**: Flutter SDK (Dart)
*   **State Management**: Provider Pattern
*   **Networking**: Dio HTTP Client dengan Interceptor Autentikasi JWT
*   **Secure Storage**: Flutter Secure Storage (untuk token JWT)
*   **Charts**: Fl Chart (untuk diagram batang keuangan)

---

## 📂 Struktur Folder Proyek

```text
rumaowner/
├── assets/                     # Gambar, ikon kategori pengumuman, dan logo
├── lib/
│   ├── core/                   # Konfigurasi Tema (Olive Green) & API Client Dio
│   ├── data/                   # Data desain statis & konstanta
│   ├── models/                 # Model objek Dart (User, Room, Tenant, Payment, Expense, dll)
│   ├── providers/              # Pengelola state aplikasi (Auth, Kamar, Keuangan, Pengaduan)
│   ├── screens/                # Antarmuka Halaman (19 screens, termasuk Detail Properti & Form Kamar)
│   └── widgets/                # Komponen UI reusable (cards, charts, custom fields)
├── pubspec.yaml                # Konfigurasi dependensi package Flutter
└── README.md                   # Dokumentasi Aplikasi Owner ini
```

---

## 🔄 Alur Kerja Spesifik Owner (Flows)

### 1. Proses Pendaftaran & Check-in Tenant Baru
Saat owner menyewakan kamar kepada penghuni baru:
1.  Owner meminta tenant membuat akun melalui aplikasi tenant atau didaftarkan di sistem.
2.  Owner membuka menu **Tenant** -> klik **Tambah Penghuni**.
3.  Owner memilih user tenant, memilih kamar yang berstatus *available*, menentukan tanggal mulai sewa (*Check-in*), serta menentukan tanggal jatuh tempo bulanan (*Billing Day*).
4.  Setelah disimpan, status kamar otomatis berubah menjadi *occupied*, dan sistem backend otomatis membangkitkan **Tagihan Bulan Pertama** berstatus *pending*.

### 2. Pengelolaan Laporan Laba Rugi
1.  Setiap tagihan bulanan yang dibayar oleh anak kos via Midtrans (atau dikonfirmasi manual oleh owner) akan tercatat sebagai **Pemasukan**.
2.  Owner menginput pengeluaran rutin kos melalui menu **Keuangan** -> **Tambah Pengeluaran**.
3.  Aplikasi secara otomatis menghitung laba bersih bulanan dengan rumus:
    $$\text{Laba Bersih} = \text{Total Pemasukan Kamar} - \text{Total Pengeluaran Operasional}$$
4.  Data disajikan dalam bentuk grafik kolom bulanan yang interaktif.

### 3. Pengendalian Komplain Fasilitas
1.  Bila ada kerusakan (misal: kebocoran pipa), owner melihat notifikasi di dashboard utama.
2.  Owner meninjau keluhan di halaman **Pengaduan** -> melihat foto bukti kerusakan.
3.  Owner mengubah status menjadi **In Progress** saat memanggil teknisi.
4.  Setelah perbaikan selesai, owner mengubah status keluhan menjadi **Resolved**.

---

## ⚙️ Cara Menjalankan Aplikasi

Pastikan perangkat Android/iOS Emulator atau HP Fisik Anda telah terhubung (`flutter devices`).

1.  Jalankan instalasi package yang dibutuhkan:
    ```bash
    flutter pub get
    ```
2.  Jalankan aplikasi dengan konfigurasi alamat IP Backend API (melalui variabel global):
    ```bash
    flutter run --dart-define="RUMA_API_BASE_URL=http://<IP_KOMPUTER_ANDA>:8080/api"
    ```
    *Atau jika menggunakan script otomatisasi di root direktori:*
    ```bash
    ../../start.sh owner
    ```

---

## 🌐 Endpoint API yang Digunakan Owner

Berikut adalah REST API utama yang diakses oleh RUMA Owner App:

| HTTP Method | Endpoint | Kegunaan |
| :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Login pemilik kos |
| `GET` | `/api/auth/me` | Mengambil profil pemilik kos |
| `GET` | `/api/boarding-houses` | Mengambil daftar properti kos milik owner |
| `POST` | `/api/boarding-houses` | Membuat kos baru |
| `GET` | `/api/rooms` | Mengambil seluruh data kamar |
| `POST` | `/api/rooms` | Menambah kamar baru |
| `PUT` | `/api/rooms/:id` | Mengubah detail kamar |
| `GET` | `/api/tenants` | Mengambil seluruh data penghuni kos |
| `POST` | `/api/tenants` | Mendaftarkan penghuni (check-in) |
| `PUT` | `/api/tenants/:id` | Mengubah data penyewa / check-out |
| `GET` | `/api/payments` | Rekap tagihan seluruh penyewa |
| `PUT` | `/api/payments/:id/confirm` | Konfirmasi manual pembayaran sewa |
| `GET` | `/api/expenses` | Mengambil daftar pengeluaran operasional |
| `POST` | `/api/expenses` | Mencatat pengeluaran operasional baru |
| `GET` | `/api/complaints` | Meninjau seluruh komplain penghuni |
| `PUT` | `/api/complaints/:id` | Memperbarui status penanganan komplain |
| `POST` | `/api/announcements` | Menyebarkan pengumuman baru |
