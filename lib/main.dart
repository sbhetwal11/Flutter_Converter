import 'package:flutter/material.dart';

void main() => runApp(const MeasuresConverterApp());

class MeasuresConverterApp extends StatelessWidget {
  const MeasuresConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ConverterScreen(),
    );
  }
}

enum Category { length, weight }

extension CategoryLabel on Category {
  String get label => this == Category.length ? 'Length' : 'Weight';
}

/// Unit definition: convert to a base unit using `toBase`.
/// - Length base = meters
/// - Weight base = kilograms
class UnitDef {
  final String name;
  final double toBase;

  const UnitDef(this.name, this.toBase);
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _valueController = TextEditingController(text: '100');

  Category _category = Category.length;

  static const lengthUnits = <UnitDef>[
    UnitDef('meters', 1.0),
    UnitDef('kilometers', 1000.0),
    UnitDef('feet', 0.3048),
    UnitDef('miles', 1609.344),
  ];

  static const weightUnits = <UnitDef>[
    UnitDef('kilograms', 1.0),
    UnitDef('grams', 0.001),
    UnitDef('pounds', 0.45359237),
    UnitDef('ounces', 0.028349523125),
  ];

  List<UnitDef> get units => _category == Category.length ? lengthUnits : weightUnits;

  late UnitDef _from = units.first;
  late UnitDef _to = units.length > 2 ? units[2] : units.last;

  String _result = '';

  void _onCategoryChanged(Category? value) {
    if (value == null) return;
    setState(() {
      _category = value;
      _from = units.first;
      _to = units.length > 2 ? units[2] : units.last;
      _result = '';
    });
  }

  void _convert() {
    final raw = _valueController.text.trim();
    final input = double.tryParse(raw);

    if (input == null) {
      setState(() => _result = 'Please enter a valid number (example: 12.5)');
      return;
    }

    // Convert: input -> base -> output
    final base = input * _from.toBase;
    final output = base / _to.toBase;

    setState(() {
      _result = '${_fmt(input)} ${_from.name} are ${_fmt(output)} ${_to.name}';
    });
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measures Converter')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _sectionTitle('Value'),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 22),
            _sectionTitle('Category'),
            DropdownButtonFormField<Category>(
              value: _category,
              items: Category.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: _onCategoryChanged,
            ),

            const SizedBox(height: 22),
            _sectionTitle('From'),
            DropdownButtonFormField<UnitDef>(
              value: _from,
              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
              onChanged: (v) => setState(() => _from = v ?? _from),
            ),

            const SizedBox(height: 22),
            _sectionTitle('To'),
            DropdownButtonFormField<UnitDef>(
              value: _to,
              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
              onChanged: (v) => setState(() => _to = v ?? _to),
            ),

            const SizedBox(height: 22),
            Center(
              child: ElevatedButton(
                onPressed: _convert,
                child: const Text('Convert'),
              ),
            ),

            const SizedBox(height: 18),
            Center(
              child: Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Center(
      child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
    );
  }
}

