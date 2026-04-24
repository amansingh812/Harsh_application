import 'package:flutter/material.dart';
import '../../apis/api_service.dart';
import '../../themes/app_colors.dart';

class AdmissionProcessWidget extends StatefulWidget {
  final User user;
  const AdmissionProcessWidget({super.key, required this.user});

  @override
  State<AdmissionProcessWidget> createState() =>
      _AdmissionProcessWidgetState();
}

class _AdmissionProcessWidgetState extends State<AdmissionProcessWidget> {
  String? _selectedSession;
  int? _expandedIndex;

  Map<String, dynamic> get _data => widget.user.admissions;

  List<String> get _sessionKeys {
    final status = _data['status'];
    if (status is Map) return status.keys.cast<String>().toList();
    return [];
  }

  List<dynamic> _stepsFor(String session) {
    final stepsMap = _data['steps_to_apply'];
    if (stepsMap is! Map) return [];
    if (stepsMap.containsKey(session)) return stepsMap[session] as List;
    if (stepsMap.containsKey('latestAdmProcess')) {
      return stepsMap['latestAdmProcess'] as List;
    }
    return [];
  }

  List<dynamic> _statusFor(String session) {
    final status = _data['status'];
    if (status is Map && status.containsKey(session)) {
      return status[session] as List;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    final keys = _sessionKeys;
    if (keys.isNotEmpty) _selectedSession = keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final schoolTimings = (data['school_timings'] ?? '').toString();
    final officeTimings = (data['office_timings'] ?? '').toString();
    final docs = data['documents'];
    final hasDocs = docs is List && docs.isNotEmpty;
    final sessions = _sessionKeys;

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
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.how_to_reg_outlined,
                      size: 20, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Admission Process',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            if (data.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      'Admission details not available',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 16),

              // ── Timings Row ──
              if (schoolTimings.isNotEmpty || officeTimings.isNotEmpty) ...[
                Row(
                  children: [
                    if (schoolTimings.isNotEmpty)
                      Expanded(
                        child: _timingCard(
                          Icons.access_time_outlined,
                          'School Timings',
                          schoolTimings,
                          const Color(0xFFE8F5E9),
                          const Color(0xFF2E7D32),
                        ),
                      ),
                    if (schoolTimings.isNotEmpty && officeTimings.isNotEmpty)
                      const SizedBox(width: 10),
                    if (officeTimings.isNotEmpty)
                      Expanded(
                        child: _timingCard(
                          Icons.work_outline,
                          'Office Timings',
                          officeTimings,
                          const Color(0xFFFFF3E0),
                          const Color(0xFFE65100),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ── Required Documents ──
              if (hasDocs) ...[
                _sectionLabel('Required Documents'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (docs as List)
                      .map<Widget>((d) => _docChip(d.toString()))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // ── Session Tabs ──
              if (sessions.isNotEmpty) ...[
                _sectionLabel('Admission Status by Session'),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: sessions.map((key) {
                      final selected = _selectedSession == key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedSession = key;
                            _expandedIndex = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xFFF0F2FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFD0D8FF),
                              ),
                            ),
                            child: Text(
                              key,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Class-wise list ──
              if (_selectedSession != null)
                _buildClassList(_selectedSession!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassList(String session) {
    final statusList = _statusFor(session);
    final stepsList = _stepsFor(session);

    // Build classId → steps map
    final Map<int, List<String>> stepsMap = {};
    for (final item in stepsList) {
      if (item is Map) {
        final classId = item['class_id'];
        final steps = item['steps'];
        if (classId != null && steps is List) {
          stepsMap[classId as int] = steps.map((s) => s.toString()).toList();
        }
      }
    }

    if (statusList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: statusList.asMap().entries.map((entry) {
        final idx = entry.key;
        final info = entry.value as Map;
        final className = (info['class'] ?? '').toString();
        final status = (info['status'] ?? '').toString();
        final statusText = (info['status_text'] ?? status).toString();
        final startDate = (info['start_date'] ?? '').toString();
        final lastDate = (info['last_date'] ?? '').toString();
        final classId = info['class_id'];
        // Check both status and status_text — API may send either "open"/"Open"/1
        final isOpen = status.toLowerCase() == 'open' ||
            statusText.toLowerCase() == 'open' ||
            status == '1';
        // Always show normalized text so UI is consistent
        final chipLabel = isOpen ? 'Open' : 'Close';
        print('🎓 Admission row: class=$className status=$status statusText=$statusText isOpen=$isOpen');
        final steps = stepsMap[classId] ?? [];
        final isExpanded = _expandedIndex == idx;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                // Row header
                InkWell(
                  onTap: steps.isNotEmpty
                      ? () => setState(() =>
                          _expandedIndex = isExpanded ? null : idx)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            className,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        _statusChip(chipLabel, isOpen),
                        if (steps.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Expanded detail
                if (isExpanded && steps.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF8F9FF),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dates
                        if (startDate.isNotEmpty || lastDate.isNotEmpty) ...[
                          Row(
                            children: [
                              if (startDate.isNotEmpty)
                                _dateBadge(
                                    Icons.calendar_today_outlined,
                                    'Opens',
                                    startDate),
                              if (startDate.isNotEmpty &&
                                  lastDate.isNotEmpty)
                                const SizedBox(width: 8),
                              if (lastDate.isNotEmpty)
                                _dateBadge(
                                    Icons.event_busy_outlined,
                                    'Last Date',
                                    lastDate),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        Text(
                          'Steps to Apply',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...steps.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _timingCard(IconData icon, String label, String value,
      Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _docChip(String doc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0D8FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined,
              size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            doc,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isOpen
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
      ),
    );
  }

  Widget _dateBadge(IconData icon, String label, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
