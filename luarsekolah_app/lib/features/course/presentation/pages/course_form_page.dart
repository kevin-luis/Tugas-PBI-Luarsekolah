import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/course_form_controller.dart';
import '../widgets/form_input_widget.dart';
import '../widgets/thumbnail_preview_widget.dart';

class CourseFormPage extends StatelessWidget {
  final bool isEdit;

  const CourseFormPage({
    Key? key,
    this.isEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourseFormController>(
      init: Get.find<CourseFormController>(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              controller.courseEntity != null ? 'Edit Kelas' : 'Informasi Kelas',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                FormInputWidget(
                  label: 'Nama Kelas',
                  controller: controller.nameController,
                  hintText: 'e.g Marketing Communication',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FormInputWidget(
                  label: 'Harga Kelas',
                  controller: controller.priceController,
                  hintText: 'e.g 1.000.000',
                  helperText: 'Masukkan dalam bentuk angka (tanpa koma)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga kelas tidak boleh kosong';
                    }
                    final price = double.tryParse(value.replaceAll('.', ''));
                    if (price == null || price < 0) {
                      return 'Masukkan harga yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kategori Kelas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF2D6F5C)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      hint: const Text('Pilih Prakerja atau SPL'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Prakerja',
                          child: Text('Prakerja'),
                        ),
                        DropdownMenuItem(
                          value: 'SPL',
                          child: Text('SPL'),
                        ),
                      ],
                      onChanged: controller.onCategoryChanged,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih kategori kelas';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 24),
                FormInputWidget(
                  label: 'URL Thumbnail Kelas',
                  controller: controller.thumbnailUrlController,
                  hintText: 'https://example.com/image.jpg',
                  helperText: 'Masukkan URL gambar thumbnail (opsional)',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.link),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!value.startsWith('http://') &&
                          !value.startsWith('https://')) {
                        return 'URL harus dimulai dengan http:// atau https://';
                      }
                    }
                    return null;
                  },
                  onChanged: controller.onThumbnailChanged,
                ),
                const SizedBox(height: 16),
                ThumbnailPreviewWidget(
                  thumbnailPath: controller.thumbnailPath,
                ),
                const SizedBox(height: 8),
                FormInputWidget(
                  label: 'Rating (Opsional)',
                  controller: controller.ratingController,
                  hintText: 'e.g 4.5',
                  helperText: 'Rating kelas dari 0.0 - 5.0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.star_outline),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final rating = double.tryParse(value.trim());
                      if (rating == null || rating < 0 || rating > 5) {
                        return 'Rating harus antara 0.0 - 5.0';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (controller.courseEntity == null)
                  FormInputWidget(
                    label: 'Dibuat Oleh (Opsional)',
                    controller: controller.createdByController,
                    hintText: 'e.g Admin, John Doe',
                    helperText: 'Nama pembuat kelas',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                if (controller.courseEntity == null) const SizedBox(height: 24),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6F5C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                controller.courseEntity != null
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Kelas',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => OutlinedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF2D6F5C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D6F5C),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatNumber(number);

    int offset = formatted.length;
    if (newValue.selection.baseOffset < oldValue.text.length) {
      offset = newValue.selection.baseOffset;
      final oldDots = '.'.allMatches(oldValue.text.substring(0, oldValue.selection.baseOffset)).length;
      final newDots = '.'.allMatches(formatted.substring(0, offset.clamp(0, formatted.length))).length;
      offset += (newDots - oldDots);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset.clamp(0, formatted.length)),
    );
  }

  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}