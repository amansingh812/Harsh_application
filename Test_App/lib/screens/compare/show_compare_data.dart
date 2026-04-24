import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_scout/screens/compare/compare_search.dart';
import 'package:school_scout/screens/details/school_details_page.dart';
import '../../apis/api_service.dart';
import '../../global/global_data.dart';
import '../../main.dart';
import '../../widgets/native_ads_widget.dart';

class ShowCompareData extends StatefulWidget {
  const ShowCompareData({super.key});

  @override
  State<ShowCompareData> createState() => _ShowCompareDataState();



}

class _ShowCompareDataState extends State<ShowCompareData> {
  List<bool> _expandedStates = [];
  User? school1;
  User? school2;
  bool hideCommonValues = false;
  bool showAllFacilities = false;

 /* @override
  void initState() {
    super.initState();
    school1 = widget.selectedSchool1;
    school2 = widget.selectedSchool2;
    _expandedStates = List.generate(categories().length, (index) => true);
  }*/
  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "CompareScreen",
    );
    school1 = GlobalData().selectedSchools.isNotEmpty
        ? GlobalData().selectedSchools[0]
        : null;

    school2 = GlobalData().selectedSchools.length > 1
        ? GlobalData().selectedSchools[1]
        : null;

    _expandedStates = List.generate(categories().length, (_) => true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    school1 = GlobalData().selectedSchools.isNotEmpty
        ? GlobalData().selectedSchools[0]
        : null;

    school2 = GlobalData().selectedSchools.length > 1
        ? GlobalData().selectedSchools[1]
        : null;
  }


  @override
  void dispose() {

    super.dispose();
  }


  /*Future<void> _selectSchool(int index) async {
    final User? selectedSchool = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompareSearch()),
    );

    if (selectedSchool != null) {
      setState(() {
        GlobalData().toggleCompare(selectedSchool);
        _expandedStates = List.generate(categories().length, (_) => true);
      });
    }
  }*/
  Future<void> _selectSchool(int index) async {
    final User? selectedSchool = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompareSearch()),
    );

    if (selectedSchool == null) return;

    setState(() {
      if (index == 1) {
        if (GlobalData().selectedSchools.isNotEmpty) {
          GlobalData().selectedSchools[0] = selectedSchool;
        } else {
          GlobalData().selectedSchools.add(selectedSchool);
        }
      } else if (index == 2) {
        if (GlobalData().selectedSchools.length > 1) {
          GlobalData().selectedSchools[1] = selectedSchool;
        } else {
          GlobalData().selectedSchools.add(selectedSchool);
        }
      }

      school1 = GlobalData().selectedSchools.isNotEmpty
          ? GlobalData().selectedSchools[0]
          : null;

      school2 = GlobalData().selectedSchools.length > 1
          ? GlobalData().selectedSchools[1]
          : null;

      GlobalData().compareCount.value =
          GlobalData().selectedSchools.length;
    });
  }


  /* void _removeSchool(int index) {
    setState(() {
      if (GlobalData().selectedSchools.length >= index) {
        GlobalData().selectedSchools.removeAt(index - 1);
      }
      GlobalData().compareCount.value = GlobalData().selectedSchools.length;
      _expandedStates = List.generate(categories().length, (_) => true);
    });
  }*/
  void _removeSchool(int index) {
    setState(() {
      if (index == 1) {
        if (GlobalData().selectedSchools.isNotEmpty) {
          GlobalData().selectedSchools.removeAt(0);
        }
      } else if (index == 2) {
        if (GlobalData().selectedSchools.length > 1) {
          GlobalData().selectedSchools.removeAt(1);
        }
      }

      // 🔥 MOST IMPORTANT: local state bhi null karo
      school1 = GlobalData().selectedSchools.isNotEmpty
          ? GlobalData().selectedSchools[0]
          : null;

      school2 = GlobalData().selectedSchools.length > 1
          ? GlobalData().selectedSchools[1]
          : null;

      GlobalData().compareCount.value =
          GlobalData().selectedSchools.length;
    });
  }


  void _clearCompareState() {
    GlobalData().selectedSchools.clear();
    GlobalData().compareCount.value = 0;
  }

  // --------------------- DATA ---------------------

  List<Map<String, List<String>>> categories() {
    return [
      {
        'Ownership': [
          school1?.ownership ?? '-',
          school2?.ownership ?? '-',
        ],
        'School Format': [
          school1?.format ?? '-',
          school2?.format ?? '-',
        ],
        'School Category': [
          school1?.coedStatus ?? '-',
          school2?.coedStatus ?? '-',
        ],
      },
      {
        'Classes Offered': [
          school1?.classesOffered ?? '-',
          school2?.classesOffered ?? '-',
        ],
        'Board': [
          school1?.boards ?? '-',
          school2?.boards ?? '-',
        ],
        'Language of Instruction': [
          school1?.medium ?? '-',
          school2?.medium ?? '-',
        ],
        'Academic Session': [
          school1?.academicSession ?? '-',
          school2?.academicSession ?? '-',
        ],
      },
      {
        'Campus Type': [
          school1?.boards ?? '-',
          school2?.boards ?? '-',
        ],
        'Campus Size': [
          school1?.builtInArea ?? '-',
          school2?.builtInArea ?? '-',
        ],
      },
      {
        'Year of Establishment': [
          school1?.yearOfEstablishment ?? '-',
          school2?.yearOfEstablishment ?? '-',
        ],
        'Student Faculty Ratio': [
          school1?.studentTeacherRatio ?? '-',
          school2?.studentTeacherRatio ?? '-',
        ],
        'Language Taught': [
          school1?.languagesTaught.join(', ') ?? '-',
          school2?.languagesTaught.join(', ') ?? '-',
        ],
      },
    ];
  }

  List<String> categoryImages() {
    return [
      'assets/images/back-to-school.png',
      'assets/images/education.png',
      'assets/images/amenities.png',
      'assets/images/school.png',
    ];
  }

  // --------------------- UI ---------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        _clearCompareState();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          automaticallyImplyLeading: false,
          title: const Text(
            'Compare Schools',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),

        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TOP BLUE HEADER + SCHOOL CARDS
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSchoolCard(1, school1),
                    _buildSchoolCard(2, school2),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // HIDE COMMON VALUES SWITCH CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildHideCommonValuesSwitch(),
              ),

              const SizedBox(height: 12),

              // CATEGORY LIST + NATIVE AD AFTER 2ND CATEGORY
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories().length + 1, // +1 for ad
                itemBuilder: (context, index) {
                  // Insert Native Ad after 2nd category (index 2)
                  if (index == 2) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NativeAdWidget(),
                    );
                  }

                  // Calculate real category index
                  final realIndex = index > 2 ? index - 1 : index;

                  return _buildCategory(realIndex);
                },

              ),
             const SizedBox(height: 100.0,),



            ],
          ),
        ),
      ),
    );
  }

  // ---------- TOP SCHOOL CARDS (FIXED HEIGHT) ----------

  Widget _buildSchoolCard(int index, User? school) {
    final width = MediaQuery.of(context).size.width * 0.42;

    return Container(
      width: width,
      height: 200, // FIXED HEIGHT
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: school == null
          ? InkWell(
        onTap: () => _selectSchool(index), // ✅ ONLY HERE
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/school_icon.png'),
              width: 80,
              height: 80,
            ),
            SizedBox(height: 12),
            Text(
              'Add School',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )

          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image + close btn
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: school.galleryImages.isNotEmpty
                    ? Image.network(
                  school.galleryImages[0],
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/dummy_image.png",
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/dummy_image.png",
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeSchool(index),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${school.address.area}, ${school.address.city.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HIDE COMMON VALUES SWITCH ----------

  Widget _buildHideCommonValuesSwitch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Hide Common Values",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: hideCommonValues,
              onChanged: (value) {
                setState(() {
                  hideCommonValues = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- CATEGORY CARD ----------

  Widget _buildCategory(int index) {
    final category = categories()[index];
    final categoryImage = categoryImages()[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedStates[index] = !_expandedStates[index];
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Image.asset(
                      categoryImage,
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getCategoryTitle(index),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _expandedStates[index]
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            if (_expandedStates[index])
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildCategoryContent(category),
              ),
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(int index) {
    switch (index) {
      case 0:
        return 'School Information';
      case 1:
        return 'Academics';
      case 2:
        return 'Campus Details';
      case 3:
        return 'Faculty Information';
      default:
        return 'Category';
    }
  }

  Widget _buildCategoryContent(Map<String, List<String>> categoryData) {
    return Column(
      children: categoryData.entries
          .where((entry) => !hideCommonValues || entry.value[0] != entry.value[1])
          .map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreyText(entry.key),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.value[0],
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                          Colors.grey.shade300,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value[1],
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );

  }

  Widget _buildGreyText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ---------- FACILITIES SECTION ----------

  Widget _buildFacilitiesSection() {
    final facilities1 = school1?.featureFacilities ?? [];
    final facilities2 = school2?.featureFacilities ?? [];

    // Show first 3 or all based on state
    final displayFacilities1 = showAllFacilities ? facilities1 : facilities1.take(3).toList();
    final displayFacilities2 = showAllFacilities ? facilities2 : facilities2.take(3).toList();

    final hasMore = facilities1.length > 3 || facilities2.length > 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/amenities.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Featured Facilities',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFacilityList(displayFacilities1),
                      ),
                      Container(
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                              Colors.grey.shade300,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildFacilityList(displayFacilities2),
                      ),
                    ],
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setState(() {
                          showAllFacilities = !showAllFacilities;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              showAllFacilities ? 'Show Less' : 'Show More',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              showAllFacilities
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityList(List facilities) {
    if (facilities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No facilities listed',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facilities.map<Widget>((facility) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  facility.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}