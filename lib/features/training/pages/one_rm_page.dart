import 'package:flutter/material.dart';
import '../utils/one_rm_calculator.dart';

class OneRmPage extends StatefulWidget {
  const OneRmPage({super.key});

  @override
  State<OneRmPage> createState() => _OneRmPageState();
}

class _OneRmPageState extends State<OneRmPage> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController(text: '5');

  double _oneRm = 0;
  Map<int, double> _table = const {};

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    final oneRm = OneRmCalculator.average(weight: weight, reps: reps);
    setState(() {
      _oneRm = oneRm;
      _table = OneRmCalculator.percentageTable(oneRm, roundTo: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora 1RM')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculate(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _repsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimación 1RM', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_oneRm > 0 ? '${_oneRm.toStringAsFixed(1)} kg' : '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tabla de porcentajes'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _table.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = _table.keys.elementAt(i);
                  final v = _table[p]!;
                  return ListTile(
                    dense: true,
                    title: Text('$p%'),
                    trailing: Text('${v.toStringAsFixed(1)} kg'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


