import 'package:flutter/material.dart';

void main() => runApp(const BharosankApp());

/// Bharosank — a transparent credit-limit worksheet built from the shopkeeper's
/// OWN rule (not a risk score). Mirrors the Go engine.
class BharosankApp extends StatelessWidget {
  const BharosankApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bharosank',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF2E7E5E), useMaterial3: true),
        home: const HomePage(),
      );
}

class Result {
  final double base, penalty, limit;
  const Result(this.base, this.penalty, this.limit);
}

/// evaluate mirrors backend/cost.go.
Result evaluate(double avgMonthly, double pct, int late, double penaltyPer) {
  final base = avgMonthly * pct / 100;
  final penalty = late * penaltyPer;
  var limit = base - penalty;
  if (limit < 0) limit = 0;
  return Result(base, penalty, limit);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _avg = TextEditingController(text: '8000');
  final _pct = TextEditingController(text: '50');
  final _late = TextEditingController(text: '2');
  final _pen = TextEditingController(text: '500');

  double _n(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final r = evaluate(_n(_avg), _n(_pct), _i(_late), _n(_pen));
    String m(double v) => '₹${v.toStringAsFixed(2)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bharosank · credit worksheet'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Your own rule — every weight visible', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _f(_avg, 'Customer avg monthly purchase ₹'),
        _f(_pct, 'Limit = this % of monthly'),
        Row(children: [Expanded(child: _f(_late, 'Recent late payments')), const SizedBox(width: 12), Expanded(child: _f(_pen, '₹ penalty per late'))]),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recommended credit limit'),
              Text(m(r.limit), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const Divider(),
              _row('Base (% of monthly)', m(r.base)),
              _row('Late-payment penalty', '− ${m(r.penalty)}'),
              const SizedBox(height: 8),
              const Text('A consistency worksheet, not a risk prediction. Why A got more than B is on the page.',
                  style: TextStyle(fontSize: 12)),
            ])),
        ),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(k), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))]),
      );

  Widget _f(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onChanged: (_) => setState(() {})),
      );
}
