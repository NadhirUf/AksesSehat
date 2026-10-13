# AksesSehat

Aplikasi bantu komunikasi untuk pasien yang tidak bisa berbahasa setempat. Pasien menunjuk bagian tubuh dan memilih keluhan, lalu aplikasi menyusun kalimat dan membacakannya dalam bahasa petugas kesehatan.

**Bahasa:** Indonesia, ไทย (Thai), English
**Status:** Modul 1 v5, versi awal untuk pengembangan dan demo.
**Privasi:** tidak ada data kesehatan yang disimpan di aplikasi.

> **Penting:** terjemahan Thai dan frasa medis masih DRAFT. Harus diperiksa penutur asli atau tenaga kesehatan sebelum dipakai di demo, proposal, atau situasi nyata. Aplikasi ini bukan pengganti penerjemah medis profesional.

## Fitur Modul 1

- Peta tubuh interaktif untuk menunjuk bagian yang sakit
- Pilihan keluhan (sakit kepala, demam, batuk, sakit perut, nyeri, lainnya)
- Skala keparahan 1 sampai 5
- Kalimat otomatis dalam bahasa pasien dan bahasa petugas
- Suara pembaca (text-to-speech) dari suara bawaan perangkat
- Layar balasan petugas dan layar darurat

## Pilih cara memakai

| Perangkat | Cara | Link |
|---|---|---|
| iPhone / iPad | Versi web (Safari) | https://nadhiruf.github.io/AksesSehat/ |
| Mac / Windows / Linux | Versi web (browser) | https://nadhiruf.github.io/AksesSehat/ |
| Android | Versi web atau aplikasi APK | [Releases](https://github.com/NadhirUf/AksesSehat/releases) |

Tidak perlu akun GitHub untuk memakai atau mengunduh.

---

## iPhone dan iPad

Aplikasi iOS asli belum tersedia. Di iPhone, pakai versi web yang bisa dipasang ke layar utama sehingga tampil seperti aplikasi.

### Membuka dan memasang ke layar utama

1. Buka **Safari** (disarankan, bukan Chrome) lalu ketik atau tempel: https://nadhiruf.github.io/AksesSehat/
2. Tunggu sampai aplikasi tampil. Pertama kali dibuka butuh internet.
3. Ketuk tombol **Bagikan** (ikon kotak dengan panah ke atas) di bagian bawah layar.
4. Gulir menu ke bawah dan ketuk **Tambah ke Layar Utama**.
5. Ketuk **Tambah** di pojok kanan atas.
6. Ikon AksesSehat muncul di layar utama. Buka dari sana.

### Mengaktifkan suara Thai di iPhone

Aplikasi memakai suara bawaan iPhone. Kalau suara Thai belum terpasang:

1. Buka **Pengaturan > Aksesibilitas > Konten Terucap > Suara** (Settings > Accessibility > Spoken Content > Voices).
2. Pilih **Thai** lalu ketuk suara yang tersedia (misalnya Kanya) dan unduh.
3. Kembali ke aplikasi dan coba tombol suara lagi.

Kalau suara tidak keluar: naikkan volume, matikan mode senyap (tombol di sisi iPhone), dan pastikan tidak sedang memakai mode **Fokus** yang membungkam media.

---

## Mac, Windows, dan Linux

1. Buka https://nadhiruf.github.io/AksesSehat/ di browser. **Safari** atau **Chrome** disarankan di Mac. Di Windows, pakai **Chrome** atau **Edge**.
2. Layar aplikasi bekerja paling nyaman dalam tampilan sempit. Kalau jendela browser terlalu lebar, kecilkan jendelanya.

### Memasang sebagai aplikasi (opsional)

- **Chrome atau Edge:** klik ikon pasang di ujung kanan kolom alamat, lalu **Pasang**.
- **Safari (macOS Sonoma ke atas):** menu **File > Tambahkan ke Dock**.

### Mengaktifkan suara Thai di Mac

1. Buka **Pengaturan Sistem > Aksesibilitas > Konten Terucap**.
2. Pada **Suara sistem**, pilih **Kelola Suara** lalu unduh suara **Thai**.
3. Muat ulang halaman aplikasi.

Di Windows: **Pengaturan > Waktu & Bahasa > Ucapan > Tambahkan suara**, lalu pilih Thai.

---

## Android

### Opsi 1: Aplikasi (APK)

1. Buka halaman [Releases](https://github.com/NadhirUf/AksesSehat/releases) di browser HP.
2. Pada rilis **AksesSehat (build terbaru)**, gulir ke **Assets** dan ketuk **app-release.apk**.
3. Setelah selesai diunduh, buka file tersebut dari notifikasi atau aplikasi **Files**.
4. Jika muncul peringatan sumber tidak dikenal, ketuk **Pengaturan**, aktifkan **Izinkan dari sumber ini**, kembali, lalu ketuk **Pasang**.
5. Jika Google Play Protect memberi peringatan, pilih **Tetap pasang**. Aplikasi ini belum ada di Play Store.
6. Buka **AksesSehat**.

### Opsi 2: Versi web

Buka https://nadhiruf.github.io/AksesSehat/ di Chrome, ketuk menu titik tiga, lalu **Tambahkan ke layar utama** atau **Instal aplikasi**.

### Mengaktifkan suara Thai di Android

1. Buka **Pengaturan > Sistem (atau Manajemen umum) > Bahasa & input > Output text-to-speech**.
2. Pastikan mesinnya **Speech Services by Google**.
3. Ketuk ikon pengaturan, lalu **Instal data suara** dan unduh **Thai**.

---

## Jika ada masalah

| Masalah | Coba ini |
|---|---|
| Halaman kosong atau tidak memuat | Muat ulang, pastikan terhubung internet, atau buka di jendela pribadi |
| Tampilan versi lama setelah pembaruan | Muat ulang paksa (Cmd+Shift+R di Mac, Ctrl+Shift+R di Windows) atau hapus data situs di pengaturan browser |
| Suara tidak keluar | Cek volume, pasang suara untuk bahasa tersebut (lihat bagian perangkat di atas), coba Safari di Apple atau Chrome di perangkat lain |
| Pesan "tidak ada suara bahasa ini" | Suara untuk bahasa itu belum terpasang di perangkat, pasang dulu |
| APK tidak ada di Releases | Buka tab **Actions** dan tunggu build **Build APK** selesai (hijau) |

---

## Membangun sendiri

### Lewat GitHub (otomatis)

Setiap kali ada perubahan di branch `main`, GitHub Actions membangun APK (workflow **Build APK**) dan versi web (workflow **Deploy Web**). Keduanya bisa dijalankan manual lewat tab **Actions > pilih workflow > Run workflow**.

Agar versi web aktif, di **Settings > Pages** pilih **Source: GitHub Actions**.

### Di komputer

Butuh [Flutter SDK](https://docs.flutter.dev/get-started/install) dan Android SDK (untuk Android).

```bash
git clone https://github.com/NadhirUf/AksesSehat.git
cd AksesSehat
flutter pub get
flutter run -d chrome          # versi web
flutter run                    # Android, HP tersambung lewat USB
flutter build apk --release    # APK: build/app/outputs/flutter-apk/app-release.apk
flutter build web --release    # web: build/web
```

## Struktur kode

| File | Isi |
|---|---|
| `lib/main.dart` | Titik masuk dan tema aplikasi |
| `lib/screens.dart` | Semua layar (beranda, peta tubuh, keluhan, kalimat, balasan, darurat) |
| `lib/body_map.dart` | Peta tubuh |
| `lib/strings.dart` | Seluruh teks tiga bahasa |
| `lib/report.dart` | Daftar keluhan dan penyusun laporan |
| `lib/speaker.dart` | Pembaca suara (flutter_tts) |
| `lib/state.dart` | Bahasa dan state aplikasi |
| `lib/ui_parts.dart` | Komponen UI bersama |

## Catatan

- Manifest Android memuat `<queries>` untuk `TTS_SERVICE` agar mesin suara terdeteksi di Android 11 ke atas. Jangan dihapus.
- Versi web memakai suara bawaan browser, jadi ketersediaan suara Thai bergantung pada perangkat dan browser.
