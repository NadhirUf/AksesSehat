import 'package:flutter/material.dart';
import 'state.dart';
import 'strings.dart';

/// Satu pilihan keluhan di layar awal. Teksnya ada di strings.dart
/// (kunci 'c_<id>' untuk label dan 'cp_<id>' untuk potongan kalimat).
class Complaint {
  const Complaint(this.id, this.icon, {this.useRegion = false, this.painful = true});
  final String id;
  final IconData icon;

  /// Kalau true, pasien diminta menunjuk bagian tubuh dulu.
  final bool useRegion;

  /// Kalau true, skala 1-5 ditanyakan sebagai "seberapa sakit".
  /// Kalau false, ditanyakan sebagai "seberapa berat" (demam, batuk, dst).
  final bool painful;

  String label([Lang? l]) => tr('c_$id', l);
}

// CATATAN: isi daftar ini hanya contoh awal. Kurator konten & QA harus
// memverifikasi frasa (semua bahasa) sebelum dipakai di demo atau proposal.
const complaints = <Complaint>[
  Complaint('headache', Icons.psychology_alt),
  Complaint('fever', Icons.thermostat, painful: false),
  Complaint('cough', Icons.air, painful: false),
  Complaint('stomach', Icons.sick),
  Complaint('pain', Icons.healing, useRegion: true),
  Complaint('other', Icons.more_horiz, useRegion: true, painful: false),
];

const feelIds = <String>[
  'stab', 'cramp', 'burn', 'throb', 'dull', 'press', 'radiate', 'numb', 'bloat', 'comes',
  'dry', 'phlegm', 'cblood', 'night', 'chills', 'sweat', 'hot',
];
const alsoIds = <String>[
  'nausea', 'vomit', 'diarrhea', 'dizzy', 'breath', 'weak', 'light', 'blurry', 'sore', 'ache',
  'rash', 'fevers', 'constip', 'noapp', 'swell', 'bruise', 'cantmove', 'urine',
];

/// Pilihan "rasa" dan "keluhan lain" yang ditawarkan untuk satu keluhan.
class SymptomProfile {
  const SymptomProfile(this.feel, this.also);
  final List<String> feel;
  final List<String> also;
}

const sinceIds = <String>['today', 'yesterday', 'days', 'week', 'unknown'];

/// Data pasien yang sedang diisi. Hanya di memori, tidak disimpan.
class Report {
  Complaint? complaint;
  String? region; // id bagian tubuh, mis. 'arm_r'
  String? since; // salah satu dari sinceIds
  int? level; // 1-5
  Set<String> feel = {}; // dari feelIds (hanya untuk keluhan nyeri)
  Set<String> also = {}; // dari alsoIds
  String note = ''; // tulisan bebas pasien (tidak diterjemahkan)

  void reset() {
    complaint = null;
    region = null;
    since = null;
    level = null;
    feel = {};
    also = {};
    note = '';
  }

  bool get hasNote => note.trim().isNotEmpty;

  /// Apakah pasien diminta menunjuk bagian tubuh dulu (menentukan jumlah langkah).
  bool get usesRegion => complaint == null || complaint!.useRegion || complaint!.id == 'stomach';
  int get totalSteps => usesRegion ? 4 : 3;

  /// Pilihan rasa dan keluhan lain menyesuaikan jenis keluhan dan bagian tubuh.
  /// CATATAN: ini contoh awal; perlu ditinjau tenaga kesehatan.
  SymptomProfile get profile {
    const head = SymptomProfile(
        ['throb', 'press', 'stab', 'comes'], ['nausea', 'vomit', 'dizzy', 'light', 'blurry', 'weak']);
    const belly = SymptomProfile(['cramp', 'burn', 'stab', 'bloat', 'comes'],
        ['nausea', 'vomit', 'diarrhea', 'constip', 'noapp', 'fevers']);
    final id = complaint?.id;
    final r = region ?? '';
    switch (id) {
      case 'headache':
        return head;
      case 'fever':
        return const SymptomProfile(
            ['chills', 'sweat', 'hot'], ['ache', 'sore', 'rash', 'nausea', 'weak', 'dizzy']);
      case 'cough':
        return const SymptomProfile(
            ['dry', 'phlegm', 'cblood', 'night'], ['breath', 'fevers', 'sore', 'weak', 'ache']);
      case 'stomach':
        return belly;
      case 'other':
        return const SymptomProfile([], ['fevers', 'weak', 'dizzy', 'nausea', 'breath', 'ache']);
    }
    if (r == 'head') return head;
    if (r == 'abdomen' || r.startsWith('ab_')) return belly;
    if (r == 'pelvis' || r == 'buttocks') {
      return const SymptomProfile(['cramp', 'burn', 'stab', 'dull', 'comes'],
          ['nausea', 'urine', 'diarrhea', 'fevers', 'weak']);
    }
    if (r == 'chest') {
      return const SymptomProfile(['press', 'stab', 'burn', 'radiate'], ['breath', 'dizzy', 'nausea', 'weak']);
    }
    if (r == 'whole' || r.isEmpty) {
      return const SymptomProfile(['dull', 'stab', 'throb', 'burn'], ['fevers', 'weak', 'dizzy', 'nausea', 'breath']);
    }
    return const SymptomProfile(
        ['dull', 'stab', 'throb', 'radiate', 'numb'], ['swell', 'bruise', 'cantmove', 'weak', 'fevers']);
  }

  /// Teks untuk disalin (kalimat petugas + catatan pasien).
  String copyText(Lang l) =>
      '${sentenceFor(l)}${hasNote ? '\n${tr('note_staff', l)}: ${note.trim()}' : ''}';

  /// Skala dibaca sebagai nyeri, kecuali keluhan memang bukan nyeri.
  bool get painful => complaint?.painful ?? true;

  /// Menyusun kalimat dalam bahasa [l]. Setiap bagian ditulis utuh per bahasa
  /// (bukan terjemahan kata per kata), supaya tata bahasanya wajar.
  String sentenceFor(Lang l) {
    final c = complaint;
    final r = region;
    if (c == null && r == null) return '${tr('s_none', l)}.';

    final parts = <String>[];
    var first = tr(c == null ? 'cp_pain' : 'cp_${c.id}', l);
    if (r != null && (c == null || c.useRegion || c.id == 'stomach')) {
      final sp = l == Lang.th ? '' : ' '; // Thai tanpa spasi antar kata
      if (c?.id == 'stomach') {
        if (r != 'abdomen') first += sp + tr('rp_$r', l);
      } else {
        if (r.startsWith('ab_')) first += sp + tr('rp_abdomen', l);
        first += sp + tr('rp_$r', l);
      }
    }
    parts.add(first);
    if (since != null) parts.add(tr('sp_$since', l));
    if (level != null) {
      parts.add(tr(painful ? 'lv_pain' : 'lv_sev', l).replaceAll('{n}', '$level'));
    }
    for (final id in feelIds) {
      if (feel.contains(id)) parts.add(tr('fe_$id', l));
    }
    for (final id in alsoIds) {
      if (also.contains(id)) parts.add(tr('al_$id', l));
    }
    return '${parts.join('. ')}.';
  }
}

final report = Report();
