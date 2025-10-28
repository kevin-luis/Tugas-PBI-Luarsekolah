import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/class_model.dart';

class AddClassPage extends StatefulWidget {
  final ClassModel? classModel;

  const AddClassPage({Key? key, this.classModel}) : super(key: key);

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _createdByController = TextEditingController();
  String? _selectedCategory;
  String? _thumbnailPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.classModel != null) {
      _nameController.text = widget.classModel!.name;
      
      // Format price dengan titik sebagai separator ribuan
      final priceInt = widget.classModel!.price.toInt();
      _priceController.text = _formatNumber(priceInt);
      
      // Handle empty categoryTag
      final category = widget.classModel!.category;
      if (category.isNotEmpty && category != 'Prakerja' && category != 'SPL') {
        _selectedCategory = _normalizeCategory(category);
      } else if (category.isEmpty) {
        _selectedCategory = null; // Biarkan null jika kosong
      } else {
        _selectedCategory = category;
      }
      
      _thumbnailUrlController.text = widget.classModel!.thumbnail ?? '';
      _ratingController.text = widget.classModel!.rating ?? '';
      _createdByController.text = widget.classModel!.createdBy ?? '';
      _thumbnailPath = widget.classModel!.thumbnail;
    }
  }

  String _normalizeCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized == 'prakerja') return 'Prakerja';
    if (normalized == 'spl') return 'SPL';
    return 'Prakerja';
  }

  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _thumbnailUrlController.dispose();
    _ratingController.dispose();
    _createdByController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori kelas terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse price: remove dots, then parse
      final priceValue = double.parse(_priceController.text.replaceAll('.', ''));
      final priceString = priceValue.toStringAsFixed(2);

      final thumbnailUrl = _thumbnailUrlController.text.trim().isNotEmpty 
          ? _thumbnailUrlController.text.trim() 
          : null;

      final rating = _ratingController.text.trim().isNotEmpty 
          ? _ratingController.text.trim() 
          : null;

      final createdBy = _createdByController.text.trim().isNotEmpty 
          ? _createdByController.text.trim() 
          : null;

      Map<String, dynamic> result;

      if (widget.classModel != null) {
        // UPDATE - Bandingkan dengan data original
        final hasNameChanged = _nameController.text.trim() != widget.classModel!.name;
        
        // Compare price: round to avoid floating point precision issues
        final originalPrice = widget.classModel!.price.round();
        final currentPrice = priceValue.round();
        final hasPriceChanged = currentPrice != originalPrice;
        
        // Compare category: handle empty category
        final originalCategory = widget.classModel!.category.toLowerCase();
        final currentCategory = _selectedCategory?.toLowerCase() ?? '';
        final hasCategoryChanged = currentCategory != originalCategory && currentCategory.isNotEmpty;
        
        final hasThumbnailChanged = thumbnailUrl != widget.classModel!.thumbnail;
        final hasRatingChanged = rating != widget.classModel!.rating;

        // Debug log
        print('=== UPDATE COMPARISON ===');
        print('Name: "${widget.classModel!.name}" → "${_nameController.text.trim()}" | Changed: $hasNameChanged');
        print('Price: ${widget.classModel!.price} → $priceValue | Changed: $hasPriceChanged');
        print('Category: "${widget.classModel!.category}" → "$_selectedCategory" | Changed: $hasCategoryChanged');
        print('Thumbnail: "${widget.classModel!.thumbnail}" → "$thumbnailUrl" | Changed: $hasThumbnailChanged');
        print('Rating: "${widget.classModel!.rating}" → "$rating" | Changed: $hasRatingChanged');

        if (!hasNameChanged && !hasPriceChanged && !hasCategoryChanged && 
            !hasThumbnailChanged && !hasRatingChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada perubahan untuk disimpan'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // PENTING: Kirim semua data, bukan hanya yang berubah
        // Karena API kemungkinan override semua field
        result = await ApiService.updateCourse(
          id: widget.classModel!.id,
          name: _nameController.text.trim(),  // Always send
          price: priceString,  // Always send
          categoryTag: currentCategory.isNotEmpty ? [currentCategory] : null,
          thumbnail: thumbnailUrl,  // Always send (bisa null)
          rating: rating,  // Always send (bisa null)
        );
      } else {
        // CREATE
        result = await ApiService.createCourse(
          name: _nameController.text.trim(),
          price: priceString,
          categoryTag: [_selectedCategory!.toLowerCase()],
          thumbnail: thumbnailUrl,
          rating: rating,
          createdBy: createdBy,
        );
      }

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.classModel != null
                    ? 'Kelas berhasil diperbarui'
                    : 'Kelas berhasil ditambahkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Terjadi kesalahan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.classModel != null ? 'Edit Kelas' : 'Informasi Kelas',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nama Kelas
            const Text(
              'Nama Kelas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g Marketing Communication',
                hintStyle: TextStyle(color: Colors.grey[400]),
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
                  borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kelas tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Harga Kelas
            const Text(
              'Harga Kelas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: 'e.g 1.000.000',
                hintStyle: TextStyle(color: Colors.grey[400]),
                helperText: 'Masukkan dalam bentuk angka (tanpa koma)',
                helperStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
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
                  borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
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

            // Kategori Kelas
            const Text(
              'Kategori Kelas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
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
                  borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
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
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih kategori kelas';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // URL Thumbnail Kelas
            const Text(
              'URL Thumbnail Kelas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _thumbnailUrlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://example.com/image.jpg',
                hintStyle: TextStyle(color: Colors.grey[400]),
                helperText: 'Masukkan URL gambar thumbnail (opsional)',
                helperStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.link),
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
                  borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL harus dimulai dengan http:// atau https://';
                  }
                }
                return null;
              },
              onChanged: (value) {
                if (value.startsWith('http')) {
                  setState(() {
                    _thumbnailPath = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Preview Thumbnail
            if (_thumbnailPath != null && _thumbnailPath!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview Thumbnail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _thumbnailPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Rating
            const Text(
              'Rating (Opsional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ratingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g 4.5',
                hintStyle: TextStyle(color: Colors.grey[400]),
                helperText: 'Rating kelas dari 0.0 - 5.0',
                helperStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.star_outline),
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
                  borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
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

            // Created By (hanya untuk create)
            if (widget.classModel == null) ...[
              const Text(
                'Dibuat Oleh (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _createdByController,
                decoration: InputDecoration(
                  hintText: 'e.g Admin, John Doe',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  helperText: 'Nama pembuat kelas',
                  helperStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
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
                    borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Button Simpan Perubahan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6F5C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.classModel != null ? 'Simpan Perubahan' : 'Tambah Kelas',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Button Kembali
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom input formatter for thousands separator
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
    
    // Preserve cursor position
    int offset = formatted.length;
    if (newValue.selection.baseOffset < oldValue.text.length) {
      // User is editing in the middle, try to maintain relative position
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