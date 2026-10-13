import 'package:flutter/foundation.dart';

/// Bahasa yang didukung. Urutan harus sama dengan urutan kolom di strings.dart.
enum Lang { id, th, en }

extension LangInfo on Lang {
  /// Kode untuk mesin teks-ke-suara Android.
  String get ttsCode => switch (this) {
        Lang.id => 'id-ID',
        Lang.th => 'th-TH',
        Lang.en => 'en-US',
      };

  /// Nama bahasa dalam bahasanya sendiri (tidak diterjemahkan).
  String get nativeName => switch (this) {
        Lang.id => 'Indonesia',
        Lang.th => 'ไทย',
        Lang.en => 'English',
      };
}

/// Pengaturan bahasa. Hanya di memori, tidak disimpan.
/// ui    = bahasa pasien (tampilan aplikasi)
/// staff = bahasa petugas (kalimat yang dibacakan dan ditampilkan ke petugas)
class AppState extends ChangeNotifier {
  Lang ui = Lang.id;
  Lang staff = Lang.th;

  void setUi(Lang l) {
    if (l == ui) return;
    ui = l;
    notifyListeners();
  }

  void setStaff(Lang l) {
    if (l == staff) return;
    staff = l;
    notifyListeners();
  }
}

final app = AppState();
