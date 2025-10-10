import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final String? loadingText; // ← teks loading opsional
  final bool enabled;
  final Future<void> Function() onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.loadingText,
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (!_isLoading && widget.enabled) {
      setState(() => _isLoading = true);
      try {
        await widget.onPressed();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.enabled && !_isLoading ? _handlePress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              widget.enabled ? const Color(0xFF077E60) : Colors.grey[300],
          foregroundColor:
              widget.enabled ? Colors.white : Colors.grey[600],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.loadingText ?? 'Mohon tunggu...', // ← default
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            : Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
