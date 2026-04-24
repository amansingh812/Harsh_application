import 'package:flutter/material.dart';
import 'package:school_scout/apis/api_service.dart';
import 'package:school_scout/apis/get_school_setrvice.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/models/mini_school_model.dart';
import 'package:school_scout/screens/details/school_details_page.dart';
import 'package:school_scout/themes/app_colors.dart';

class MostShortlistedWidget extends StatelessWidget {
  final List<MiniSchool> schools;
  final VoidCallback? onDetailsReturned;

  const MostShortlistedWidget({super.key, required this.schools, this.onDetailsReturned});

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 18,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Most Shortlisted',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Schools parents love the most',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Horizontal Scroll ──
        // The Stack + Positioned(left/right: -12) breaks out of the parent's
        // 12px horizontal padding so the cards span edge-to-edge.
        SizedBox(
          height: 260,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -12,
                right: -12,
                top: 0,
                bottom: 0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  // 16px left indent aligns first card with header text
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  itemCount: schools.length,
                  itemBuilder: (context, index) =>
                      _MiniSchoolCard(school: schools[index], onDetailsReturned: onDetailsReturned),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Mini School Card  (matches _buildSchoolCard style)
// ─────────────────────────────────────────────────────────
class _MiniSchoolCard extends StatefulWidget {
  final MiniSchool school;
  final VoidCallback? onDetailsReturned;
  const _MiniSchoolCard({required this.school, this.onDetailsReturned});

  @override
  State<_MiniSchoolCard> createState() => _MiniSchoolCardState();
}

class _MiniSchoolCardState extends State<_MiniSchoolCard> {
  bool _loading = false;

  Future<void> _onViewDetails() async {
    // Fast path
    for (final u in GlobalData().users) {
      if (u.id == widget.school.id) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SchoolDetailsPage(user: u)),
        );
        widget.onDetailsReturned?.call();
        return;
      }
    }

    // Slow path
    setState(() => _loading = true);
    try {
      final service = GetSchoolService();
      final fetched = await service.fetchUserBySchoolId(widget.school.id);
      if (!mounted) return;
      if (fetched.isNotEmpty) {
        // Cache thumbnail so it's available on next render
        GlobalData().buildThumbnailCache(fetched);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SchoolDetailsPage(user: fetched.first)),
        );
        if (mounted) widget.onDetailsReturned?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load school details. Try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final school = widget.school;
    final boards = school.boardsList;
    final boardDisplay = boards.isNotEmpty ? boards.join(' • ') : '';
    // Cards span full screen width; ~30dp of the next card peeks to hint scrollability
    final cardWidth = (MediaQuery.of(context).size.width - 62) / 2;

    final thumbnail = GlobalData().schoolThumbnails[school.id];

    final List<Color> gradientColors = school.isVerified
        ? [const Color(0xFF1B5E20), const Color(0xFF43A047)]
        : school.isPartner
            ? [AppColors.primary, const Color(0xFF5C6BC0)]
            : [AppColors.primary, const Color(0xFF1E3A8A)];

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _loading ? null : _onViewDetails,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / Gradient placeholder ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbnail != null
                      ? Image.network(
                          thumbnail,
                          key: ValueKey(school.id),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : Image.asset('assets/images/dummy_image.png',
                                      fit: BoxFit.cover),
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/dummy_image.png',
                              fit: BoxFit.cover),
                        )
                      : Image.asset('assets/images/dummy_image.png',
                          fit: BoxFit.cover),
                    // Board badge top-right
                    if (boardDisplay.isNotEmpty)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            boardDisplay,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Verified / Partner badge bottom-left
                    if (school.isVerified || school.isPartner)
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Row(
                          children: [
                            if (school.isVerified)
                              _badge(
                                icon: Icons.verified_rounded,
                                label: 'Verified',
                                color: const Color(0xFF2E7D32),
                              ),
                            if (school.isVerified && school.isPartner)
                              const SizedBox(width: 6),
                            if (school.isPartner)
                              _badge(
                                icon: Icons.handshake_outlined,
                                label: 'Partner',
                                color: AppColors.accentGold,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: Text(
                      school.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (school.area.isNotEmpty || school.city.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              if (school.area.isNotEmpty) school.area,
                              if (school.city.isNotEmpty) school.city,
                            ].join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  if (school.classesOffered.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        school.classesOffered,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
              // Loading overlay
              if (_loading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradient(List<Color> colors, MiniSchool school) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          school.name.isNotEmpty ? school.name[0].toUpperCase() : 'S',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.25),
          ),
        ),
      ),
    );
  }

  Widget _badge(
      {required IconData icon,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
