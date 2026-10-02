
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NexoraToolsPage extends StatelessWidget {
  const NexoraToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: const [
        Text('Nexora Tools', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        SizedBox(height: 4),
        Text('Utility cepat yang langsung jalan di perangkat.'),
        SizedBox(height: 18),
        _CalculatorTool(),
        SizedBox(height: 14),
        _TextTool(),
        SizedBox(height: 14),
        _ConverterTool(),
        SizedBox(height: 14),
        _JsonTool(),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _CalculatorTool extends StatefulWidget {
  const _CalculatorTool();

  @override
  State<_CalculatorTool> createState() => _CalculatorToolState();
}

class _CalculatorToolState extends State<_CalculatorTool> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  String _op = '+';
  String _result = '0';

  void _calculate() {
    final a = double.tryParse(_a.text.replaceAll(',', '.'));
    final b = double.tryParse(_b.text.replaceAll(',', '.'));
    if (a == null || b == null) {
      setState(() => _result = 'Input tidak valid');
      return;
    }

    double value;
    switch (_op) {
      case '-':
        value = a - b;
        break;
      case '×':
        value = a * b;
        break;
      case '÷':
        if (b == 0) {
          setState(() => _result = 'Tidak bisa ÷ 0');
          return;
        }
        value = a / b;
        break;
      default:
        value = a + b;
    }

    setState(() => _result = _format(value));
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ToolCard(
      icon: Icons.calculate_rounded,
      title: 'Quick Calculator',
      subtitle: 'Tambah, kurang, kali, dan bagi.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _a, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'A'))),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _op,
                items: const [
                  DropdownMenuItem(value: '+', child: Text('+')),
                  DropdownMenuItem(value: '-', child: Text('-')),
                  DropdownMenuItem(value: '×', child: Text('×')),
                  DropdownMenuItem(value: '÷', child: Text('÷')),
                ],
                onChanged: (value) => setState(() => _op = value ?? '+'),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _b, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'B'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: FilledButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate_rounded), label: const Text('Hitung'))),
              const SizedBox(width: 10),
              Expanded(child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)), child: Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextTool extends StatefulWidget {
  const _TextTool();

  @override
  State<_TextTool> createState() => _TextToolState();
}

class _TextToolState extends State<_TextTool> {
  final _input = TextEditingController();
  String _output = '';

  void _set(String value) => setState(() => _output = value);

  Future<void> _copy() async {
    if (_output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _output));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasil disalin.')));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ToolCard(
      icon: Icons.text_fields_rounded,
      title: 'Text Studio',
      subtitle: 'Rapikan dan ubah teks tanpa server.',
      child: Column(
        children: [
          TextField(
            controller: _input,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tulis atau tempel teks...',
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => _set(_input.text.toUpperCase()), child: const Text('UPPER')),
              OutlinedButton(onPressed: () => _set(_input.text.toLowerCase()), child: const Text('lower')),
              OutlinedButton(onPressed: () => _set(_input.text.replaceAll(RegExp(r'\s+'), ' ').trim()), child: const Text('RAPIKAN')),
              OutlinedButton(onPressed: () => _set(_input.text.split('').reversed.join()), child: const Text('REVERSE')),
            ],
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
              child: SelectableText(_output),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(onPressed: _copy, icon: const Icon(Icons.copy_rounded), label: const Text('Copy')),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConverterTool extends StatefulWidget {
  const _ConverterTool();

  @override
  State<_ConverterTool> createState() => _ConverterToolState();
}

class _ConverterToolState extends State<_ConverterTool> {
  final _input = TextEditingController(text: '1');
  String _unit = 'm';
  String _target = 'km';

  double _toMeter(double value, String unit) {
    switch (unit) {
      case 'mm':
        return value / 1000;
      case 'cm':
        return value / 100;
      case 'km':
        return value * 1000;
      case 'ft':
        return value * 0.3048;
      case 'mi':
        return value * 1609.344;
      default:
        return value;
    }
  }

  double _fromMeter(double value, String unit) {
    switch (unit) {
      case 'mm':
        return value * 1000;
      case 'cm':
        return value * 100;
      case 'km':
        return value / 1000;
      case 'ft':
        return value / 0.3048;
      case 'mi':
        return value / 1609.344;
      default:
        return value;
    }
  }

  String get _result {
    final value = double.tryParse(_input.text.replaceAll(',', '.'));
    if (value == null) return 'Input tidak valid';
    final result = _fromMeter(_toMeter(value, _unit), _target);
    if (result == result.roundToDouble()) return result.toInt().toString();
    return result.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const units = ['mm', 'cm', 'm', 'km', 'ft', 'mi'];
    return _ToolCard(
      icon: Icons.swap_horiz_rounded,
      title: 'Unit Converter',
      subtitle: 'Konversi panjang secara offline.',
      child: Column(
        children: [
          TextField(controller: _input, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Nilai')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: DropdownButtonFormField<String>(value: _unit, items: [for (final u in units) DropdownMenuItem(value: u, child: Text(u))], onChanged: (v) => setState(() => _unit = v ?? 'm'), decoration: const InputDecoration(labelText: 'Dari'))),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(value: _target, items: [for (final u in units) DropdownMenuItem(value: u, child: Text(u))], onChanged: (v) => setState(() => _target = v ?? 'km'), decoration: const InputDecoration(labelText: 'Ke'))),
            ],
          ),
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)), child: Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _JsonTool extends StatefulWidget {
  const _JsonTool();

  @override
  State<_JsonTool> createState() => _JsonToolState();
}

class _JsonToolState extends State<_JsonTool> {
  final _input = TextEditingController();
  String _output = '';

  void _format() {
    try {
      final data = jsonDecode(_input.text);
      const encoder = JsonEncoder.withIndent('  ');
      setState(() => _output = encoder.convert(data));
    } catch (error) {
      setState(() => _output = 'JSON tidak valid: ' + error.toString());
    }
  }

  void _minify() {
    try {
      final data = jsonDecode(_input.text);
      setState(() => _output = jsonEncode(data));
    } catch (error) {
      setState(() => _output = 'JSON tidak valid: ' + error.toString());
    }
  }

  Future<void> _copy() async {
    if (_output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _output));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON disalin.')));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ToolCard(
      icon: Icons.data_object_rounded,
      title: 'JSON Studio',
      subtitle: 'Format atau minify JSON langsung di perangkat.',
      child: Column(
        children: [
          TextField(
            controller: _input,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: '{"name":"Nexora","version":1}',
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: FilledButton(onPressed: _format, child: const Text('FORMAT'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: _minify, child: const Text('MINIFY'))),
            ],
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 260),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
              child: SingleChildScrollView(child: SelectableText(_output, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(onPressed: _copy, icon: const Icon(Icons.copy_rounded), label: const Text('Copy')),
            ),
          ],
        ],
      ),
    );
  }
}
