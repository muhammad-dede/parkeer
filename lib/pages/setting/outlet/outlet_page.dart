import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/models/outlet.dart';
import 'package:parkeer/repositories/outlet_repository.dart';

class OutletPage extends StatefulWidget {
  const OutletPage({super.key});

  @override
  State<OutletPage> createState() => _OutletPageState();
}

class _OutletPageState extends State<OutletPage> {
  final repo = OutletRepository();

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final outlet = await repo.get();

    _nameController.text = outlet.name;
    _addressController.text = outlet.address;
    _phoneController.text = outlet.phone;
    _emailController.text = outlet.email;

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    await repo.save(
      Outlet(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Informasi outlet berhasil disimpan")),
    );
  }

  InputDecoration decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget gap() => const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informasi Outlet")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label("Nama Outlet"),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: decoration("Masukkan nama outlet"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Nama outlet wajib diisi";
                        }
                        return null;
                      },
                    ),

                    gap(),

                    label("Alamat"),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: decoration("Masukkan alamat outlet"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Alamat wajib diisi";
                        }
                        return null;
                      },
                    ),

                    gap(),

                    label("Nomor Telepon"),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: decoration("08123456789"),
                    ),

                    gap(),

                    label("Email"),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: decoration("admin@outlet.com"),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(
                              r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                          return "Format email tidak valid";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: _saving ? null : save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
