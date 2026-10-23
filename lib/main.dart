import 'package:flutter/material.dart';

import 'ads.dart';
import 'logic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdService.instance.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFEF4444);
    return MaterialApp(
      title: 'Calculadora de Descuentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

InputDecoration _dec(String label, {String? suffix, String? prefix}) =>
    InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixText: prefix,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );

const _num = TextInputType.numberWithOptions(decimal: true);

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.showAds = true, this.tab = 0});

  final bool showAds;
  final int tab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _tab = widget.tab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Descuentos')),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.percent), label: 'Descuento'),
              NavigationDestination(
                  icon: Icon(Icons.compare_arrows), label: 'Comparar'),
            ],
          ),
          if (widget.showAds) const BannerAdWidget(),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [DiscountTab(), CompareTab()],
      ),
    );
  }
}

class DiscountTab extends StatefulWidget {
  const DiscountTab({super.key});

  @override
  State<DiscountTab> createState() => _DiscountTabState();
}

class _DiscountTabState extends State<DiscountTab> {
  final _price = TextEditingController(text: '1200');
  final _d1 = TextEditingController(text: '30');
  final _d2 = TextEditingController(text: '10');
  final _tax = TextEditingController(text: '16');
  int _n = 0;

  @override
  void dispose() {
    for (final c in [_price, _d1, _d2, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ds = [parseNumber(_d1.text), parseNumber(_d2.text)]
        .where((d) => d > 0)
        .toList();
    final r = applyDiscounts(parseNumber(_price.text), ds,
        taxPercent: parseNumber(_tax.text));

    void changed() => setState(() {
          if (++_n % 10 == 0) AdService.instance.maybeShowInterstitial(every: 1);
        });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF97316)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Precio final',
                  style: TextStyle(color: Colors.white70)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(money(r.total),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              Text(
                'Ahorras ${money(r.saved)} (${r.savedPercent.toStringAsFixed(1)}%)',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
            controller: _price,
            keyboardType: _num,
            onChanged: (_) => changed(),
            decoration: _dec('Precio original', prefix: '\$ ')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
                controller: _d1,
                keyboardType: _num,
                onChanged: (_) => changed(),
                decoration: _dec('Descuento 1', suffix: '%')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
                controller: _d2,
                keyboardType: _num,
                onChanged: (_) => changed(),
                decoration: _dec('Descuento 2', suffix: '%')),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
            controller: _tax,
            keyboardType: _num,
            onChanged: (_) => changed(),
            decoration: _dec('IVA / impuesto', suffix: '%')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(children: [
            _row('Precio original', money(r.original)),
            _row('Descuento combinado',
                '${combinedDiscount(ds).toStringAsFixed(2)}%'),
            _row('Precio con descuento', money(r.afterDiscount)),
            _row('Impuesto', money(r.tax)),
            const Divider(),
            _row('Total a pagar', money(r.total), bold: true),
          ]),
        ),
      ],
    );
  }
}

Widget _row(String a, String b, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(a)),
        Text(b,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 18 : 14)),
      ]),
    );

class CompareTab extends StatefulWidget {
  const CompareTab({super.key});

  @override
  State<CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends State<CompareTab> {
  final _p = [
    TextEditingController(text: '45'),
    TextEditingController(text: '78'),
    TextEditingController(text: '120'),
  ];
  final _q = [
    TextEditingController(text: '500'),
    TextEditingController(text: '1000'),
    TextEditingController(text: '1800'),
  ];

  @override
  void dispose() {
    for (final c in [..._p, ..._q]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prices = _p.map((c) => parseNumber(c.text)).toList();
    final qs = _q.map((c) => parseNumber(c.text)).toList();
    final best = bestOffer(prices, qs);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('¿Cuál conviene más?',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const Text('Compara el precio por unidad (gramo, litro, pieza…).'),
        const SizedBox(height: 12),
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: best == i ? theme.colorScheme.primaryContainer : null,
              border: Border.all(
                  color: best == i
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: best == i ? 2 : 1),
            ),
            child: Column(children: [
              Row(children: [
                Text('Oferta ${String.fromCharCode(65 + i)}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (best == i)
                  const Chip(
                      avatar: Icon(Icons.emoji_events, size: 18),
                      label: Text('Mejor precio')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                      controller: _p[i],
                      keyboardType: _num,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec('Precio', prefix: '\$ ')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                      controller: _q[i],
                      keyboardType: _num,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec('Cantidad')),
                ),
              ]),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Por unidad: \$${unitPrice(prices[i], qs[i]).isFinite ? unitPrice(prices[i], qs[i]).toStringAsFixed(4) : '—'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}
