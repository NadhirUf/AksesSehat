import 'package:flutter/material.dart';
import 'screens.dart';
import 'strings.dart';

/// Kepala langkah: "Langkah 2 dari 4", batang kemajuan, dan pertanyaan besar.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.total, required this.title});
  final int step;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('step_of').replaceAll('{a}', '$step').replaceAll('{b}', '$total'), style: t.bodyMedium),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: step / total,
              minHeight: 6,
              backgroundColor: kTealTint,
              color: kTeal,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: t.headlineMedium),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Satu baris pilihan, lebar penuh dan rata. [multi] = boleh pilih banyak.
class PickRow extends StatelessWidget {
  const PickRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });
  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: selected ? kTeal : kLine, width: selected ? 2 : 1.2),
    );
    final icon = selected
        ? (multi ? Icons.check_box : Icons.check_circle)
        : (multi ? Icons.check_box_outline_blank : Icons.radio_button_unchecked);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? kTealTint : Colors.white,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: () {
            tick();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.3,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: kInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, size: 26, color: selected ? kTeal : const Color(0xFF7A8791)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
