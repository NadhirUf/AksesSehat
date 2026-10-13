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
- Suara pembaca (text-to-speech) dari suara bawaan HP
- Layar balasan petugas dan layar darurat

## Unduh dan pasang di HP Android

Tidak perlu komputer dan tidak perlu akun GitHub (selama repo ini Public).

1. Buka halaman **Releases** di browser HP: https://github.com/NadhirUf/AksesSehat/releases
2. Pada rilis **AksesSehat (build terbaru)**, gulir ke bagian **Assets**, lalu ketuk **app-release.apk** untuk mengunduh.
3. Setelah selesai, ketuk notifikasi unduhan atau buka file dari aplikasi **Files**.
4. Jika muncul peringatan pemasangan dari sumber tidak dikenal, ketuk **Pengaturan**, aktifkan **Izinkan dari sumber ini** untuk browser yang dipakai, lalu kembali dan ketuk **Pasang**.
5. Jika Google Play Protect memberi peringatan, pilih **Tetap pasang** (aplikasi ini belum dipublikasikan di Play Store).
6. Buka aplikasi **AksesSehat**, pilih **Bahasa kamu** dan **Bahasa petugas** di beranda, lalu ketuk bagian tubuh atau keluhan.

Kalau halaman Releases belum ada file APK, berarti build otomatis belum selesai. Cek tab **Actions** dan tunggu sampai tandanya hijau.

Pengguna iPhone: build iOS belum disediakan.

### Agar suara bisa dibaca

Suara memakai mesin text-to-speech bawaan HP, dan bisa offline kalau paket suara bahasanya sudah terpasang. Kalau suara tidak keluar:

1. Buka **Pengaturan > Sistem (atau Manajemen umum) > Bahasa & input > Output text-to-speech**.
2. Pastikan mesinnya **Speech Services by Google**.
3. Buka **Instal data suara** dan unduh bahasa yang dibutuhkan (terutama **Thai**).

## Membangun sendiri

### Lewat GitHub (otomatis)

Setiap kali ada perubahan di branch `main`, GitHub Actions membangun APK dan memperbarui rilis **latest**. Bisa juga dijalankan manual lewat tab **Actions > Build APK > Run workflow**. Build memakan waktu sekitar 5 sampai 10 menit.

### Di komputer

Butuh [Flutter SDK](https://docs.flutter.dev/get-started/install) dan Android SDK.

```bash
git clone https://github.com/NadhirUf/AksesSehat.git
cd AksesSehat
flutter pub get
flutter run                    # HP tersambung lewat USB
flutter build apk --release    # hasil: build/app/outputs/flutter-apk/app-release.apk
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

Manifest Android memuat `<queries>` untuk `TTS_SERVICE` agar mesin suara terdeteksi di Android 11 ke atas. Jangan dihapus.
