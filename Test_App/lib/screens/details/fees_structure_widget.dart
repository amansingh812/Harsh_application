import 'package:flutter/material.dart';
import '../../apis/api_service.dart';
import '../../themes/app_colors.dart';

class FeesStructureWidget extends StatefulWidget {
  final User user;
  const FeesStructureWidget({super.key, required this.user});

  @override
  State<FeesStructureWidget> createState() => _FeesStructureWidgetState();
}

class _FeesStructureWidgetState extends State<FeesStructureWidget> {
  bool _showAll = false;
  static const int _previewCount = 5;

  String _formatFee(dynamic value) {
    if (value == null) return '–';
    final int amount =
        (value is num) ? value.toInt() : (int.tryParse(value.toString()) ?? 0);
    if (amount == 0) return '–';
    final str = amount.toString();
    if (str.length <= 3) return '₹$str';
    String result = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    while (remaining.length > 2) {
      result = '${remaining.substring(remaining.length - 2)},$result';
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) result = '$remaining,$result';
    return '₹$result';
  }

  @override
  Widget build(BuildContext context) {
    final fees = widget.user.feesStructure;
    final entries = fees.entries.toList();
    final showToggle = entries.length > _previewCount;
    final displayedEntries =
        (!_showAll && showToggle) ? entries.take(_previewCount).toList() : entries;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Fees Structure',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            if (fees.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      'Fee details not available',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 16),

              // ── Table Header ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Class / Grade',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Annual Fee',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Fee Rows ──
              ...displayedEntries.asMap().entries.map((entry) {
                final idx = entry.key;
                final feeEntry = entry.value;
                return _feeRow(feeEntry.key, feeEntry.value, idx.isEven);
              }),

              // ── Show More / Less ──
              if (showToggle) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _showAll = !_showAll),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAll
                              ? 'Show Less'
                              : 'Show ${entries.length - _previewCount} More',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAll
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ── Disclaimer ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fees shown are indicative annual amounts. '
                        'Please verify with the school before proceeding.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feeRow(String className, dynamic fee, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              className,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _formatFee(fee),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
