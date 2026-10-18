// AksesSehat Modul 2: label obat bersuara (offline).
// Versi untuk nfc_manager 4.x (memakai NdefAndroid dari nfc_manager_android,
// dicocokkan dengan source nfc_manager 4.2.0). Tidak perlu paket nfc_manager_ndef.
// BELUM DIUJI di perangkat. Uji di HP Android sungguhan.
//
// Format data di stiker (satu record MIME, teks UTF-8 dipisah "|"):
//   nama|kali_per_hari|waktu|lama_hari
//   contoh: Ambroxol 30mg|3|sesudah makan|5
// Tanpa nama pasien. Data DEMO saja, isi obat asli harus diverifikasi apoteker.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Tipe MIME dibuat pendek supaya hemat memori NTAG213 (144 byte).
const String _mime = 'application/x-as';
// Batas aman isi teks (byte). Sisanya dipakai header NDEF.
const int _maxBytes = 110;
// Tempel kedua harus terjadi dalam waktu ini setelah bacaan selesai.
const Duration _confirmWindow = Duration(seconds: 15);
// Abaikan deteksi beruntun yang terlalu cepat (HP masih menempel).
const Duration _minGap = Duration(seconds: 2);

class Rule {
  final String name;
  final int times;
  final String when;
  final int days;
  Rule(this.name, this.times, this.when, this.days);

  String encode() => '$name|$times|$when|$days';

  static Rule? decode(String s) {
    final p = s.split('|');
    if (p.length != 4) return null;
    final t = int.tryParse(p[1]);
    final d = int.tryParse(p[3]);
    if (t == null || d == null || t < 1) return null;
    return Rule(p[0], t, p[2], d);
  }
}

class Modul2Screen extends StatefulWidget {
  const Modul2Screen({super.key});

  @override
  State<Modul2Screen> createState() => _Modul2ScreenState();
}

class _Modul2ScreenState extends State<Modul2Screen> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _nameCtl = TextEditingController();

  static const List<String> _whenOptions = [
    'sebelum makan',
    'sesudah makan',
    'bersama makan',
    'sebelum tidur',
  ];

  bool _nfcOk = true;
  bool _patientMode = true;
  String _status = 'Tempelkan HP ke stiker obat.';

  int _times = 3;
  String _when = 'sesudah makan';
  int _days = 5;

  String? _lastUid;
  DateTime? _lastReadAt;
  DateTime? _lastEvent;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage('id-ID');
    await _tts.awaitSpeakCompletion(true);
    var ok = false;
    String? why;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      why = 'Label obat bersuara hanya tersedia di aplikasi Android yang punya NFC.';
    } else {
      try {
        final availability = await NfcManager.instance.checkAvailability();
        ok = availability == NfcAvailability.enabled;
        if (!ok) {
          why = availability == NfcAvailability.disabled
              ? 'NFC di HP ini belum menyala. Nyalakan NFC di Pengaturan, lalu buka layar ini lagi.'
              : 'HP ini tidak mendukung NFC.';
        }
      } catch (_) {
        why = 'NFC tidak dapat diakses di perangkat ini.';
      }
    }
    if (!mounted) return;
    setState(() {
      _nfcOk = ok;
      if (why != null) _status = why;
    });
    if (ok) await _startPatientSession();
  }

  @override
  void dispose() {
    _stop();
    _tts.stop();
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  Future<void> _say(String text) async {
    if (mounted) setState(() => _status = text);
    await _tts.speak(text);
  }

  // ---------- Helper tag ----------

  String? _uid(NfcTag tag) {
    final id = NfcTagAndroid.from(tag)?.id;
    if (id == null) return null;
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String? _readPayload(NfcTag tag) {
    final msg = NdefAndroid.from(tag)?.cachedNdefMessage;
    if (msg == null) return null;
    for (final r in msg.records) {
      if (r.typeNameFormat == TypeNameFormat.media &&
          utf8.decode(r.type) == _mime) {
        return utf8.decode(r.payload);
      }
    }
    return null;
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------- Mode pasien ----------

  Future<void> _startPatientSession() async {
    await _stop();
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (tag) async => _onPatientTag(tag),
    );
  }

  Future<void> _onPatientTag(NfcTag tag) async {
    final now = DateTime.now();
    if (_lastEvent != null && now.difference(_lastEvent!) < _minGap) return;
    _lastEvent = now;

    final uid = _uid(tag);
    final raw = _readPayload(tag);
    final rule = raw == null ? null : Rule.decode(raw);
    if (uid == null || rule == null) {
      await _say('Stiker ini belum berisi data obat AksesSehat.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final countKey = 'cnt_${uid}_${_dayKey(now)}';
    final count = prefs.getInt(countKey) ?? 0;

    final isConfirm = _lastUid == uid &&
        _lastReadAt != null &&
        now.difference(_lastReadAt!) <= _confirmWindow + _minGap;

    if (isConfirm) {
      // Tempel kedua: catat minum.
      _lastUid = null;
      _lastReadAt = null;
      if (count >= rule.times) {
        await _say(
            'Hari ini sudah $count dari ${rule.times} kali. Tidak dicatat lagi. Jika ragu, tanyakan ke apoteker.');
        return;
      }
      final n = count + 1;
      await prefs.setInt(countKey, n);
      final hist = prefs.getStringList('hist_$uid') ?? <String>[];
      hist.add(now.toIso8601String());
      await prefs.setStringList('hist_$uid', hist);
      await _say('Tercatat. Sudah minum $n dari ${rule.times} kali hari ini.');
    } else {
      // Tempel pertama (atau di luar jendela): hanya membacakan.
      final tail = count >= rule.times
          ? 'Hari ini sudah $count dari ${rule.times} kali. Jika ragu, tanyakan ke apoteker.'
          : 'Hari ini baru $count dari ${rule.times} kali. Untuk mencatat sudah minum, tempelkan lagi dalam 15 detik.';
      _lastUid = null;
      _lastReadAt = null;
      await _say(
          '${rule.name}. Diminum ${rule.times} kali sehari, ${rule.when}, selama ${rule.days} hari. $tail Untuk keterangan lebih lanjut, tanyakan ke apoteker atau dokter.');
      // Jendela konfirmasi dihitung setelah suara selesai.
      _lastUid = uid;
      _lastReadAt = DateTime.now();
    }
  }

  // ---------- Mode pengisi ----------

  Future<void> _writeSticker() async {
    final name = _nameCtl.text.replaceAll('|', ' ').trim();
    if (name.isEmpty) {
      setState(() => _status = 'Isi nama obat dulu.');
      return;
    }
    final rule = Rule(name, _times, _when, _days);
    final bytes = utf8.encode(rule.encode());
    if (bytes.length > _maxBytes) {
      setState(() => _status =
      'Teks terlalu panjang (${bytes.length} byte, maksimal $_maxBytes). Persingkat nama obat.');
      return;
    }

    await _stop();
    setState(() => _status = 'Tempelkan stiker ke belakang HP...');
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (tag) async {
        String msg;
        try {
          final ndef = NdefAndroid.from(tag);
          if (ndef == null || !ndef.isWritable) {
            msg = 'Stiker ini tidak bisa ditulis.';
          } else {
            final message = NdefMessage(records: [
              NdefRecord(
                typeNameFormat: TypeNameFormat.media,
                type: Uint8List.fromList(utf8.encode(_mime)),
                identifier: Uint8List(0),
                payload: Uint8List.fromList(bytes),
              ),
            ]);
            // Ukuran record NDEF pendek: 3 byte header + panjang tipe + isi.
            final size = 3 + _mime.length + bytes.length;
            if (size > ndef.maxSize) {
              msg =
              'Data terlalu besar untuk stiker ini ($size byte, maksimal ${ndef.maxSize}).';
            } else {
              await ndef.writeNdefMessage(message);
              msg = 'Berhasil ditulis: ${rule.encode()}';
            }
          }
        } catch (e) {
          msg = 'Gagal menulis: $e';
        }
        await _stop();
        if (mounted) setState(() => _status = msg);
      },
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modul 2: Label obat bersuara')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Pasien')),
              ButtonSegment(value: false, label: Text('Pengisi')),
            ],
            selected: {_patientMode},
            onSelectionChanged: (s) async {
              setState(() {
                _patientMode = s.first;
                _status = _patientMode
                    ? 'Tempelkan HP ke stiker obat.'
                    : 'Isi data obat, lalu tekan Tulis ke stiker.';
              });
              if (!_nfcOk) return;
              if (_patientMode) {
                await _startPatientSession();
              } else {
                await _stop();
              }
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Semantics(
                liveRegion: true,
                child: Text(_status, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_patientMode) ..._fillerForm(),
        ],
      ),
    );
  }

  List<Widget> _fillerForm() {
    return [
      TextField(
        controller: _nameCtl,
        decoration: const InputDecoration(
          labelText: 'Nama obat dan kekuatan (contoh: Ambroxol 30mg)',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        value: _times,
        decoration: const InputDecoration(
            labelText: 'Berapa kali sehari', border: OutlineInputBorder()),
        items: [for (var i = 1; i <= 6; i++) DropdownMenuItem(value: i, child: Text('$i kali'))],
        onChanged: (v) => setState(() => _times = v ?? 3),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _when,
        decoration: const InputDecoration(
            labelText: 'Waktu minum', border: OutlineInputBorder()),
        items: [for (final w in _whenOptions) DropdownMenuItem(value: w, child: Text(w))],
        onChanged: (v) => setState(() => _when = v ?? 'sesudah makan'),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        value: _days,
        decoration: const InputDecoration(
            labelText: 'Lama minum (hari)', border: OutlineInputBorder()),
        items: [for (var i = 1; i <= 30; i++) DropdownMenuItem(value: i, child: Text('$i hari'))],
        onChanged: (v) => setState(() => _days = v ?? 5),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 64,
        child: FilledButton(
          onPressed: _nfcOk ? _writeSticker : null,
          child: const Text('Tulis ke stiker', style: TextStyle(fontSize: 20)),
        ),
      ),
    ];
  }
}