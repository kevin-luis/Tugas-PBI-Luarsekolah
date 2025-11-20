import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FieldType { generic, email, phone, password }

enum ValidationDisplayMode {
  alwaysShow,      // Selalu tampilkan semua kriteria
  hideOnValid,     // Sembunyikan kriteria yang sudah valid
  hideAllOnValid,  // Sembunyikan semua kriteria ketika semua valid
}

class ValidationRule {
  final String message;
  final bool Function(String) validate;
  final IconData successIcon;
  final IconData failIcon;

  ValidationRule({
    required this.message,
    required this.validate,
    this.successIcon = Icons.check_circle,
    this.failIcon = Icons.error,
  });
}

class DynamicTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FieldType type;
  final List<ValidationRule>? rules;
  final String? hintText;
  final bool showCriteria;
  final ValidationDisplayMode displayMode;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(bool)? onValidationChanged;

  const DynamicTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.type = FieldType.generic,
    this.rules,
    this.hintText,
    this.showCriteria = true,
    this.displayMode = ValidationDisplayMode.alwaysShow,
    this.obscureText,
    this.keyboardType,
    this.inputFormatters,
    this.onValidationChanged,
  }) : super(key: key);

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  late List<bool> _ruleResults;
  late FocusNode _focusNode;
  bool _touched = false;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscure = widget.type == FieldType.password ? (widget.obscureText ?? true) : false;
    _ruleResults = List.filled(widget.rules?.length ?? 0, false);
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_touched) {
      setState(() => _touched = true);
    }
  }

  void _onTextChanged() {
    if (widget.onValidationChanged != null) {
      final isValid = widget.rules == null
          ? widget.controller.text.isNotEmpty
          : widget.rules!.every((r) => r.validate(widget.controller.text));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onValidationChanged!(isValid);
      });
    }

    if (widget.rules == null) return;
    final text = widget.controller.text;
    setState(() {
      for (int i = 0; i < widget.rules!.length; i++) {
        _ruleResults[i] = widget.rules![i].validate(text);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  TextInputType _keyboardType() {
    switch (widget.type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.password:
        return TextInputType.text;
      case FieldType.generic:
        return TextInputType.text;
    }
  }

  Widget _buildCriteriaList() {
    if (!_touched || widget.rules == null || widget.rules!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cek apakah semua kriteria valid
    final allValid = _ruleResults.every((result) => result);

    // Jika mode hideAllOnValid dan semua valid, sembunyikan semua
    if (widget.displayMode == ValidationDisplayMode.hideAllOnValid && allValid) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(widget.rules!.length, (i) {
        final rule = widget.rules![i];
        final valid = _ruleResults[i];

        // Jika mode hideOnValid dan kriteria ini valid, skip/sembunyikan
        if (widget.displayMode == ValidationDisplayMode.hideOnValid && valid) {
          return const SizedBox.shrink();
        }

        final color = valid ? Colors.green : Colors.red;
        final icon = valid ? rule.successIcon : rule.failIcon;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rule.message,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          focusNode: _focusNode,
          controller: widget.controller,
          keyboardType: widget.keyboardType ?? _keyboardType(),
          inputFormatters: widget.inputFormatters,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFA7AAB9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFA7AAB9), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            suffixIcon: widget.type == FieldType.password
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        _buildCriteriaList(),
      ],
    );
  }
}