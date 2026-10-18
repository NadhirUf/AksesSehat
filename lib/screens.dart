import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'body_map.dart';
import 'ui_parts.dart';
import 'report.dart';
import 'speaker.dart';
import 'state.dart';
import 'strings.dart';
import 'modul2_screen.dart';

const kTeal = Color(0xFF0B6F78);
const kTealTint = Color(0xFFE6F3F4);
const kInk = Color(0xFF1B2630);
const kBg = Color(0xFFF7F8F6);
const kLine = Color(0x590B6F78);

void go(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

/// Getaran halus saat memilih. Membantu pengguna Tuli dan pengguna netra
/// memastikan ketukannya terdaftar.
void tick() => HapticFeedback.selectionClick();

/// Membacakan teks. Kalau suara bahasa itu belum terpasang di HP, tampilkan
/// petunjuk cara memasangnya (bukan diam saja).
Future<void> speakWithNotice(BuildContext context, String text, Lang lang) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = tr('voice_missing').replaceAll('{lang}', tr('vn_${lang.name}'));
  final result = await Speaker.speak(text, lang);
  if (result != SpeakResult.ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16, height: 1.4)),
        duration: const Duration(seconds: 8),
      ));
  }
}

// ------------------------------------------------------------ Komponen umum

/// Tombol besar (tinggi minimal 60) untuk semua aksi utama.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = true,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final ic = Icon(icon, size: 26);
    if (primary) {
      return FilledButton.icon(onPressed: onPressed, icon: ic, label: text);
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: ic,
      label: text,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        foregroundColor: kTeal,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
        side: const BorderSide(color: kTeal, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Bilah bawah yang selalu terlihat. Tombol "Lanjut" tidak akan terdorong
/// keluar layar, berapa pun ukuran huruf atau tinggi layarnya.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Pilihan bertanda: terpilih = isi teal + teks putih + centang.
/// Jadi tidak hanya mengandalkan warna.
class Choice extends StatelessWidget {
  const Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kInk,
          ),
        ),
      ),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      selectedColor: kTeal,
      backgroundColor: Colors.white,
      side: const BorderSide(color: kTeal, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (_) {
        tick();
        onTap();
      },
    );
  }
}

/// Tiga tombol bahasa. Nama bahasa selalu ditulis dalam bahasanya sendiri.
class LangPicker extends StatelessWidget {
  const LangPicker({super.key, required this.value, required this.onChanged});
  final Lang value;
  final ValueChanged<Lang> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final l in Lang.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: l == Lang.values.last ? 0 : 8),
              child: _LangButton(
                lang: l,
                selected: l == value,
                onTap: () {
                  tick();
                  onChanged(l);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.lang, required this.selected, required this.onTap});
  final Lang lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) const Icon(Icons.check, size: 20),
          if (selected) const SizedBox(width: 4),
          Text(lang.nativeName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3)),
        ],
      ),
    );
    const pad = EdgeInsets.symmetric(horizontal: 6);
    return Semantics(
      button: true,
      selected: selected,
      child: selected
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52), padding: pad),
              child: content,
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                padding: pad,
                foregroundColor: kTeal,
                side: const BorderSide(color: kTeal, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: content,
            ),
    );
  }
}

// ---------------------------------------------------------------- Layar 1
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Beranda mendengarkan perubahan bahasa dan menggambar ulang dirinya.
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final t = Theme.of(context).textTheme;
        final scale =
            (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(1.0, 2.0).toDouble();
        return Scaffold(
          appBar: AppBar(title: const Text('AksesSehat')),
          bottomNavigationBar: BottomBar(
            children: [
              BigButton(
                label: tr('point_body'),
                icon: Icons.accessibility_new,
                onPressed: () {
                  report.reset();
                  go(context, const BodyMapScreen());
                },
              ),
              const SizedBox(height: 10),
              BigButton(
                label: 'Label obat bersuara',
                icon: Icons.medication,
                primary: false,
                onPressed: () => go(context, const Modul2Screen()),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB3261E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      go(context, const EmergencyScreen());
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 28),
                    label: Text(tr('urgent_btn')),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kLine, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('lang_you'), style: t.bodyMedium),
                        const SizedBox(height: 6),
                        LangPicker(value: app.ui, onChanged: app.setUi),
                        const SizedBox(height: 14),
                        Text(tr('lang_staff'), style: t.bodyMedium),
                        const SizedBox(height: 6),
                        LangPicker(value: app.staff, onChanged: app.setStaff),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(tr('home_q'), style: t.headlineMedium),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25 / scale,
                    children: [for (final c in complaints) _ComplaintCard(c)],
                  ),
                  const SizedBox(height: 18),
                  Center(child: Text(tr('privacy'), style: t.bodyMedium)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard(this.c);
  final Complaint c;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: c.label(),
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            tick();
            report.reset();
            report.complaint = c;
            // Keluhan yang butuh lokasi (nyeri, lainnya): tunjuk tubuh dulu.
            go(
              context,
              c.id == 'stomach'
                  ? const AbdomenScreen()
                  : c.useRegion
                      ? const BodyMapScreen()
                      : const DetailsScreen(),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kLine, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(c.icon, size: 40, color: kTeal),
                const SizedBox(height: 8),
                Text(c.label(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Layar 2
class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});
  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  bool back = false;

  void _pick(String id) {
    tick();
    setState(() => report.region = id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = report.region;
    // Bagian perut yang sudah dirinci (ab_*) tetap ditandai sebagai 'abdomen'.
    final selected = (r != null && r.startsWith('ab_')) ? 'abdomen' : r;
    const cap = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: kInk);

    return Scaffold(
      appBar: AppBar(title: Text(tr('body_title'))),
      bottomNavigationBar: BottomBar(
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              r == null ? tr('sel_none') : '${tr('sel_prefix')}: ${tr('r_$r')}',
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          BigButton(
            label: tr('next'),
            icon: Icons.arrow_forward,
            onPressed: r == null
                ? null
                : () => go(context, selected == 'abdomen' ? const AbdomenScreen() : const DetailsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              Text(tr('body_hint'), style: t.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(value: false, label: Text(tr('view_front'))),
                  ButtonSegment<bool>(value: true, label: Text(tr('view_back'))),
                ],
                selected: {back},
                onSelectionChanged: (s) {
                  tick();
                  setState(() => back = s.first);
                },
                style: SegmentedButton.styleFrom(minimumSize: const Size(0, 52)),
              ),
              const SizedBox(height: 12),
              Choice(label: tr('r_whole'), selected: selected == 'whole', onTap: () => _pick('whole')),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Stack(
                  children: [
                    BodyFigure(back: back, selected: selected, onPick: _pick),
                    Positioned(left: 0, top: 0, child: Text(tr(back ? 'your_left' : 'your_right'), style: cap)),
                    Positioned(right: 0, top: 0, child: Text(tr(back ? 'your_right' : 'your_left'), style: cap)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zoom bagian perut: 9 area dengan nama yang mudah dipahami.
/// Kanan pasien ada di KIRI layar (seperti berhadapan dengan pasien).
class AbdomenScreen extends StatefulWidget {
  const AbdomenScreen({super.key});
  @override
  State<AbdomenScreen> createState() => _AbdomenScreenState();
}

class _AbdomenScreenState extends State<AbdomenScreen> {
  static const rows = [
    ['ab_ru', 'ab_mu', 'ab_lu'],
    ['ab_r', 'ab_m', 'ab_l'],
    ['ab_rl', 'ab_ml', 'ab_ll'],
  ];

  void _pick(String id) {
    tick();
    setState(() => report.region = id);
  }

  Widget _cell(String id) {
    final sel = report.region == id;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Semantics(
          button: true,
          selected: sel,
          label: tr('r_$id'),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _pick(id),
            child: Ink(
              height: 96,
              decoration: BoxDecoration(
                color: sel ? kTeal : kTealTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kTeal, width: sel ? 3.5 : 1.8),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel)
                        const Icon(Icons.check, color: Colors.white, size: 24)
                      else if (id == 'ab_m')
                        const Icon(Icons.radio_button_unchecked, color: kTeal, size: 18),
                      Text(
                        tr('r_$id'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = report.region;
    final ready = r != null && (r == 'abdomen' || r.startsWith('ab_'));
    return Scaffold(
      appBar: AppBar(title: Text(tr('ab_title'))),
      bottomNavigationBar: BottomBar(
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              !ready ? tr('sel_none') : '${tr('sel_prefix')}: ${tr('r_$r')}',
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          BigButton(
            label: tr('next'),
            icon: Icons.arrow_forward,
            onPressed: ready ? () => go(context, const DetailsScreen()) : null,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          children: [
            Text(tr('ab_hint'), style: t.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('your_right'), style: t.titleMedium),
                Text(tr('your_left'), style: t.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            for (final row in rows) Row(children: [for (final id in row) _cell(id)]),
            const SizedBox(height: 14),
            Choice(label: tr('ab_all'), selected: r == 'abdomen', onTap: () => _pick('abdomen')),
          ],
        ),
      ),
    );
  }
}

/// Rasa keluhan dan keluhan lain. Pilihannya menyesuaikan jenis keluhan dan
/// bagian tubuh (lihat Report.profile). Semua boleh dilewati; kalau tidak
/// ada pilihan yang cocok, pasien bisa menulis sendiri.
class FeelScreen extends StatefulWidget {
  const FeelScreen({super.key});
  @override
  State<FeelScreen> createState() => _FeelScreenState();
}

class _FeelScreenState extends State<FeelScreen> {
  final Set<String> feel = {...report.feel};
  final Set<String> also = {...report.also};
  final TextEditingController note = TextEditingController(text: report.note);
  final SymptomProfile prof = report.profile;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void _toggle(Set<String> s, String id) =>
      setState(() => s.contains(id) ? s.remove(id) : s.add(id));

  Widget _list(List<String> ids, String prefix, Set<String> s) => Column(
        children: [
          for (final id in ids)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PickRow(
                label: tr('$prefix$id'),
                selected: s.contains(id),
                multi: true,
                onTap: () => _toggle(s, id),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasFeel = prof.feel.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(tr('feel_title'))),
      bottomNavigationBar: BottomBar(
        children: [
          BigButton(
            label: tr('next'),
            icon: Icons.arrow_forward,
            onPressed: () {
              report.feel = {...feel};
              report.also = {...also};
              report.note = note.text.trim();
              go(context, const SentenceScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          children: [
            StepHeader(
              step: report.usesRegion ? 3 : 2,
              total: report.totalSteps,
              title: hasFeel ? tr('feel_q') : tr('also_q'),
            ),
            Text(tr('optional'), style: t.bodyMedium),
            const SizedBox(height: 12),
            if (hasFeel) ...[
              _list(prof.feel, 'fe_', feel),
              const SizedBox(height: 20),
              Text(tr('also_q'), style: t.titleLarge),
              const SizedBox(height: 10),
            ],
            _list(prof.also, 'al_', also),
            const SizedBox(height: 20),
            Text(tr('note_label'), style: t.titleLarge),
            const SizedBox(height: 10),
            TextField(
              controller: note,
              maxLength: 120,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: tr('note_hint'),
                helperText: tr('note_caption'),
                helperMaxLines: 2,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Layar 3
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String? since = report.since;
  int? level = report.level;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final painful = report.painful;
    // Kedua pilihan wajib, supaya tidak ada informasi yang hilang diam-diam
    // dari kalimat yang diterima petugas. "Tidak tahu" tersedia untuk durasi.
    final ready = since != null && level != null;

    return Scaffold(
      appBar: AppBar(title: Text(tr('details_title'))),
      bottomNavigationBar: BottomBar(
        children: [
          if (!ready)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(tr('need_choose'), textAlign: TextAlign.center, style: t.bodyMedium),
            ),
          BigButton(
            label: tr('next'),
            icon: Icons.arrow_forward,
            onPressed: !ready
                ? null
                : () {
                    report.since = since;
                    report.level = level;
                    go(context, const FeelScreen());
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          children: [
            StepHeader(
              step: report.usesRegion ? 2 : 1,
              total: report.totalSteps,
              title: tr('since_q'),
            ),
            for (final id in sinceIds)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PickRow(
                  label: tr('s_$id'),
                  selected: since == id,
                  onTap: () => setState(() => since = id),
                ),
              ),
            const SizedBox(height: 24),
            Text(tr(painful ? 'pain_q' : 'sev_q'), style: t.headlineMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var n = 1; n <= 5; n++)
                  Expanded(
                    child: _LevelTile(
                      n: n,
                      painful: painful,
                      selected: level == n,
                      onTap: () {
                        tick();
                        setState(() => level = n);
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('low'), style: t.bodyMedium),
                Text(tr(painful ? 'pain_high' : 'sev_high'), style: t.bodyMedium),
              ],
            ),
            const SizedBox(height: 14),
            // Pilihan juga ditulis sebagai teks dan diumumkan pembaca layar.
            Semantics(
              liveRegion: true,
              child: Text(
                level == null ? '' : tr('level_chosen').replaceAll('{n}', '$level'),
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.n,
    required this.painful,
    required this.selected,
    required this.onTap,
  });
  final int n;
  final bool painful;
  final bool selected;
  final VoidCallback onTap;

  static const faces = <IconData>[
    Icons.sentiment_very_satisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_very_dissatisfied,
  ];

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : kTeal;
    return Semantics(
      button: true,
      selected: selected,
      label: tr(painful ? 'lv_pain' : 'lv_sev').replaceAll('{n}', '$n'),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kTeal : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kTeal, width: selected ? 3 : 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(faces[n - 1], size: 32, color: fg),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) const Icon(Icons.check, size: 18, color: Colors.white),
                  Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? Colors.white : kInk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Layar 4
class SentenceScreen extends StatefulWidget {
  const SentenceScreen({super.key});
  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  @override
  void dispose() {
    Speaker.stop();
    super.dispose();
  }

  /// Ringkasan keluhan dalam bahasa pasien, supaya pasien bisa memeriksa
  /// sebelum petugas membaca.
  List<(IconData, String, String)> _rows() {
    final c = report.complaint;
    final r = report.region;
    final rows = <(IconData, String, String)>[
      (Icons.sick_outlined, tr('sum_complaint'), tr('c_${c?.id ?? 'pain'}')),
    ];
    if (r != null && (c == null || c.useRegion || c.id == 'stomach')) {
      rows.add((Icons.accessibility_new, tr('sum_where'), tr('r_$r')));
    }
    if (report.since != null) {
      rows.add((Icons.schedule, tr('sum_since'), tr('s_${report.since}')));
    }
    if (report.level != null) {
      final txt = tr(report.painful ? 'lv_pain' : 'lv_sev').replaceAll('{n}', '${report.level}');
      rows.add((Icons.speed, tr('sum_level'), txt));
    }
    final feel = [for (final id in feelIds) if (report.feel.contains(id)) tr('fe_$id')];
    if (feel.isNotEmpty) rows.add((Icons.touch_app_outlined, tr('sum_feel'), feel.join('\n')));
    final also = [for (final id in alsoIds) if (report.also.contains(id)) tr('al_$id')];
    if (also.isNotEmpty) rows.add((Icons.add_circle_outline, tr('sum_also'), also.join('\n')));
    if (report.hasNote) rows.add((Icons.edit_note, tr('note_staff'), report.note));
    return rows;
  }

  Widget _row(TextTheme t, (IconData, String, String) r) {
    final isLevel = r.$1 == Icons.speed && report.level != null;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(r.$1, color: kTeal, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.$2, style: t.bodyMedium),
                  Text(
                    r.$3,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.4, color: kInk),
                  ),
                  if (isLevel) _LevelBar(report.level!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final staffText = report.sentenceFor(app.staff);
    final same = app.staff == app.ui;
    final rows = _rows();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('sentence_title')),
        actions: [
          TextButton.icon(
            onPressed: () {
              report.reset();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.restart_alt),
            label: Text(tr('start_over')),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: Speaker.speaking,
            builder: (context, on, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (on)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(liveRegion: true, child: Text(tr('speaking'), style: t.bodyMedium)),
                  ),
                BigButton(
                  label: on ? tr('stop') : tr('speak'),
                  icon: on ? Icons.stop : Icons.volume_up,
                  onPressed: on
                      ? () => Speaker.stop()
                      : () {
                          HapticFeedback.mediumImpact();
                          speakWithNotice(context, staffText, app.staff);
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          BigButton(
            label: tr('show_staff'),
            icon: Icons.fullscreen,
            primary: false,
            onPressed: () => go(
              context,
              FullTextScreen(
                text: staffText,
                note: report.hasNote ? '${tr('note_staff', app.staff)}: ${report.note}' : '',
              ),
            ),
          ),
          const SizedBox(height: 10),
          BigButton(
            label: tr('staff_reply'),
            icon: Icons.chat_bubble_outline,
            primary: false,
            onPressed: () => go(context, const ReplyScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            // Kalimat untuk petugas (bahasa petugas), besar dan jelas.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kTeal, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    same ? tr('for_staff') : '${tr('for_staff')} (${app.staff.nativeName})',
                    style: t.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    staffText,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.45, color: kInk),
                  ),
                  if (report.hasNote) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${tr('note_staff', app.staff)}: ${report.note}',
                      style: const TextStyle(fontSize: 18, height: 1.4, color: kInk),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ringkasan dalam bahasa pasien, supaya pasien bisa memeriksa.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              decoration: BoxDecoration(
                color: kTealTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(tr('sum_title'), style: t.titleMedium)),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: report.copyText(app.staff)));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('copied'))),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        label: Text(tr('copy_btn')),
                      ),
                    ],
                  ),
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: kLine),
                    _row(t, rows[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skala 1-5 sebagai batang bertanda, bukan hanya warna.
class _LevelBar extends StatelessWidget {
  const _LevelBar(this.level);
  final int level;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Expanded(
                child: Container(
                  height: 12,
                  margin: EdgeInsets.only(right: i < 5 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= level ? kTeal : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kTeal, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullTextScreen extends StatelessWidget {
  const FullTextScreen({super.key, required this.text, this.note = ''});
  final String text;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTeal,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: Colors.white),
                        ),
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            note,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, height: 1.4, color: Colors.white),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          tr('tap_back', app.staff),
                          style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kTeal,
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(tr('back_to_app', app.staff)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Layar 5
class ReplyScreen extends StatefulWidget {
  const ReplyScreen({super.key});
  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  String? shown; // kunci balasan petugas yang sedang ditampilkan
  String? answer; // 'yes' | 'no' | 'idk'
  String cat = 'cat_guide';

  // Contoh awal; isi final ditentukan bersama tenaga kesehatan.
  static const groups = <String, List<String>>{
    'cat_guide': ['rep_1', 'rep_2', 'rep_7', 'rep_8', 'rep_9'],
    'cat_ask': ['rep_3', 'rep_6', 'rep_10', 'rep_11', 'rep_14'],
    'cat_act': ['rep_4', 'rep_5', 'rep_12', 'rep_13'],
  };

  @override
  void dispose() {
    Speaker.stop();
    super.dispose();
  }

  void _answer(String k) {
    tick();
    setState(() => answer = k);
    speakWithNotice(context, tr(k, app.staff), app.staff);
  }

  Widget _ans(String k, IconData icon) => Expanded(
        child: FilledButton.tonal(
          onPressed: () => _answer(k),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(76),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            side: answer == k ? const BorderSide(color: kTeal, width: 3) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 4),
              Text(
                tr(k),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final same = app.staff == app.ui;
    final k = shown;

    return Scaffold(
      appBar: AppBar(title: Text(tr('staff_reply'))),
      bottomNavigationBar: BottomBar(
        children: [
          // Jawaban pasien: tombol memakai bahasa pasien; hasilnya dibacakan
          // dan ditampilkan dalam bahasa petugas.
          Align(
            alignment: Alignment.centerLeft,
            child: Text(tr('patient_answer'), style: t.bodyMedium),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ans('yes', Icons.check),
              const SizedBox(width: 10),
              _ans('no', Icons.close),
              const SizedBox(width: 10),
              _ans('idk', Icons.help_outline),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Panel atas selalu terlihat: pesan untuk pasien dan jawaban pasien.
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kTealTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k == null ? tr('reply_prompt', app.staff) : tr(k),
                      style: TextStyle(
                        fontSize: k == null ? 18 : 30,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: kInk,
                      ),
                    ),
                    if (k != null && !same) ...[
                      const SizedBox(height: 6),
                      Text(tr(k, app.staff), style: t.bodyMedium),
                    ],
                    if (answer != null) ...[
                      const Divider(height: 24, color: kLine),
                      Row(
                        children: [
                          Expanded(child: Text(tr('patient_said', app.staff), style: t.bodyMedium)),
                          Text(
                            tr(answer!, app.staff),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kInk),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final c in groups.keys)
                    ButtonSegment<String>(value: c, label: Text(tr(c, app.staff))),
                ],
                selected: {cat},
                onSelectionChanged: (s) {
                  tick();
                  setState(() => cat = s.first);
                },
                style: SegmentedButton.styleFrom(minimumSize: const Size(0, 52)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                children: [
                  for (final r in groups[cat]!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PickRow(
                        label: tr(r, app.staff),
                        selected: shown == r,
                        onTap: () => setState(() => shown = r),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------- Bantuan segera
/// Layar merah besar untuk memanggil petugas. Pesan ditulis dalam bahasa
/// petugas dan dibacakan otomatis. Ini bukan pengganti layanan gawat darurat.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) speakWithNotice(context, tr('urgent_msg', app.staff), app.staff);
    });
  }

  @override
  void dispose() {
    Speaker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFB3261E);
    final same = app.staff == app.ui;
    return Scaffold(
      backgroundColor: red,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 72),
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          tr('urgent_msg', app.staff),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 38, fontWeight: FontWeight.w800, height: 1.4, color: Colors.white),
                        ),
                      ),
                      if (!same) ...[
                        const SizedBox(height: 20),
                        Text(
                          tr('urgent_msg'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, height: 1.4, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: red),
                    onPressed: () => speakWithNotice(context, tr('urgent_msg', app.staff), app.staff),
                    icon: const Icon(Icons.volume_up),
                    label: Text(tr('speak')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(tr('back_to_app', app.staff)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
