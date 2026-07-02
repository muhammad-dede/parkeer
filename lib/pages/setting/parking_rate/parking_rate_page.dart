import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/models/parking_rate.dart';
import 'package:parkeer/models/parking_rate_detail.dart';
import 'package:parkeer/repositories/parking_rate_repository.dart';

class ParkingRatePage extends StatefulWidget {
  const ParkingRatePage({super.key});

  @override
  State<ParkingRatePage> createState() => _ParkingRatePageState();
}

class _ParkingRatePageState extends State<ParkingRatePage> {
  late final ParkingRateRepository _repository;

  ParkingRate? _parkingRate;

  bool _loading = true;
  bool _saving = false;

  final List<_RuleControllers> rules = [];

  final minimumController = TextEditingController();
  final maximumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = ParkingRateRepository.instance;
    _loadData();
  }

  @override
  void dispose() {
    for (final r in rules) {
      r.dispose();
    }
    minimumController.dispose();
    maximumController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final result = await _repository.get();

    if (result == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _parkingRate = result.$1;

      for (final r in rules) {
        r.dispose();
      }
      rules.clear();

      for (final detail in result.$2) {
        rules.add(
          _RuleControllers(
            from: detail.fromMinute ~/ 60,
            to: detail.toMinute == null ? null : detail.toMinute! ~/ 60,
            price: detail.price.toInt(),
          ),
        );
      }

      minimumController.text = _parkingRate!.minimumCharge.toInt().toString();

      maximumController.text = (_parkingRate!.maximumDailyCharge ?? 0)
          .toInt()
          .toString();

      _loading = false;
    });
  }

  int? _parseIntOrNull(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  bool _validate() {
    for (final r in rules) {
      final from = int.tryParse(r.fromController.text.trim());
      final price = int.tryParse(r.priceController.text.trim());
      final toText = r.toController.text.trim();
      final to = toText.isEmpty ? null : int.tryParse(toText);

      if (from == null || price == null) {
        _showError('Pastikan semua field "dari" dan "harga" berupa angka.');
        return false;
      }

      if (toText.isNotEmpty && to == null) {
        _showError(
          'Field "sampai" harus berupa angka atau dikosongkan untuk tanpa batas.',
        );
        return false;
      }

      if (to != null && to <= from) {
        _showError('Nilai "sampai" harus lebih besar dari "dari".');
        return false;
      }
    }

    final minimum = _parseIntOrNull(minimumController.text);
    if (minimum == null) {
      _showError('Tarif minimum harus berupa angka.');
      return false;
    }

    final maxText = maximumController.text.trim();
    if (maxText.isNotEmpty && _parseIntOrNull(maxText) == null) {
      _showError('Tarif maksimal harian harus berupa angka atau dikosongkan.');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _save() async {
    if (_parkingRate == null) {
      _showError('Data tarif belum siap.');
      return;
    }

    if (!_validate()) return;

    setState(() => _saving = true);

    try {
      final updatedRate = _parkingRate!.copyWith(
        minimumCharge: double.parse(minimumController.text.trim()),
        maximumDailyCharge: maximumController.text.trim().isEmpty
            ? null
            : double.parse(maximumController.text.trim()),
      );

      final details = rules.map((r) {
        final from = int.parse(r.fromController.text.trim());
        final toText = r.toController.text.trim();
        final to = toText.isEmpty ? null : int.parse(toText);
        final price = int.parse(r.priceController.text.trim());

        return ParkingRateDetail(
          parkingRateId: _parkingRate!.id!,
          fromMinute: from * 60,
          toMinute: to == null ? null : to * 60,
          price: price.toDouble(),
        );
      }).toList();

      await _repository.update(updatedRate, details);

      if (!mounted) return;

      setState(() {
        _parkingRate = updatedRate;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarif berhasil disimpan.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Gagal menyimpan tarif: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atur Tarif Parkir")),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Simpan Tarif",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard(),

                  const SizedBox(height: 20),

                  const Text(
                    "Aturan Tarif",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  _infoRuleCard(),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ...List.generate(
                          rules.length,
                          (index) => _ruleItem(index),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              rules.add(
                                _RuleControllers(from: 0, to: null, price: 0),
                              );
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "+ Tambah Aturan",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Pengaturan Tambahan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      child: Column(
                        children: [
                          _textField(
                            controller: minimumController,
                            label: "Tarif Minimum",
                            helper: "Biaya minimum yang harus dibayarkan.",
                          ),

                          const SizedBox(height: 20),

                          _textField(
                            controller: maximumController,
                            label: "Maksimal Tarif Harian (Opsional)",
                            helper:
                                "Biaya maksimal dalam 24 jam. Kosongkan jika tidak ada batas.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time_filled, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Tarif akan dihitung berdasarkan durasi parkir sesuai dengan aturan di bawah.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRuleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(child: Text("Masukkan jumlah jam dan harga")),
        ],
      ),
    );
  }

  Widget _ruleItem(int index) {
    final rule = rules[index];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.drag_indicator),

          const SizedBox(width: 8),

          Expanded(child: _smallField(controller: rule.fromController)),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text("s.d."),
          ),

          Expanded(child: _smallField(controller: rule.toController)),

          const SizedBox(width: 8),

          Expanded(
            child: _smallField(controller: rule.priceController, prefix: "Rp "),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                rules[index].dispose();
                rules.removeAt(index);
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _smallField({
    required TextEditingController controller,
    String? suffix,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        border: InputBorder.none,
        prefixText: prefix,
        helperText: suffix,
        helperStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        helperMaxLines: 1,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(prefixText: " Rp "),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 5),
        Text(helper, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _RuleControllers {
  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController priceController;

  _RuleControllers({required int from, required int? to, required int price})
    : fromController = TextEditingController(text: from.toString()),
      toController = TextEditingController(text: to?.toString() ?? ''),
      priceController = TextEditingController(text: price.toString());

  void dispose() {
    fromController.dispose();
    toController.dispose();
    priceController.dispose();
  }
}
