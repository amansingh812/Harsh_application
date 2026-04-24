import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_scout/apis/filter_schools_service.dart';
import 'package:school_scout/hive/mappers/user_hive_to_user.dart';
import 'package:school_scout/screens/compare/show_compare_data.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import '../../apis/remove_shortlisted_school_service.dart';
import '../../apis/shortlist_api_call.dart';

import '../../helper/shortlist_helper.dart';
import '../../hive/models/user_hive.dart';
import '../../main.dart';
import '../../model/filter_schools_request.dart';
import '../../widgets/filter_component.dart';
import '../../widgets/location_modal.dart';

import '../../global/global_data.dart';
import '../../apis/api_service.dart';
import '../../widgets/native_ads_widget.dart';
import '../launch/home_loader_screen.dart';
import '../login/login_page.dart';
import '../other/search_page.dart';
import 'school_details_page.dart';

class SchoolList extends StatefulWidget {
  @override
  _SchoolListState createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  final TextEditingController _citySelectionController =
  TextEditingController();
  final ShortlistApiCall shortlistApiCall = ShortlistApiCall();
  final TextEditingController _searchController = TextEditingController();

  String _selectedValue = 'Day School';
  late GlobalData globalData;
  List<User> filteredSchools = [];
  List<User> displayedSchools = [];
  String searchQuery = '';
  String _selectedLocation = 'Bangalore';
  Map<String, List<String>> activeFilters = {};

  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isFilterMode = false;
  bool _isApiLoading = false;
  int _filterOffset = 0;
  final int _filterLimit = 20;
  late Box<UserHive> schoolBox;
  bool _showFilterLoader = false;
  List<User> _preFilterCache = [];

  String mobileNumber = GlobalData().mobNumber.toString();
  FilterSchoolRequest? lastFilterRequest;



  //bool _isPageLoading = false;
//  bool showSkeleton = false;



 /* @override
  void initState() {
    super.initState();
    globalData = GlobalData();
    _citySelectionController.text = globalData.city;
    filteredSchools = globalData.users;
    displayedSchools = filteredSchools;
    schoolBox = Hive.box<UserHive>('schools');
    _loadNextPage();
  }*/
  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "SchoolListScreen",
    );
    globalData = GlobalData();
    _citySelectionController.text = globalData.city;

    schoolBox = Hive.box<UserHive>('schools'); // ✅ INIT HIVE

    _loadFromCache(); // ✅ MEMORY → HIVE → EMPTY
  }


  @override
  void dispose() {
    _citySelectionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetPagination({bool autoLoad = true}) {
    _currentPage = 0;
    displayedSchools.clear();
    _hasMore = true;

    if (_isFilterMode) {
      _filterOffset = 0;
    }

    if (autoLoad) {
      _loadNextUiPage();
    }
  }



  void _loadFromCache() {
    // 🔥 HARD RESET – sab kuch saaf
    filteredSchools.clear();
    displayedSchools.clear();
    _currentPage = 0;
    _hasMore = true;

    // 🔒 filter mode me cache touch nahi
    if (_isFilterMode) return;

    // 1️⃣ MEMORY (GlobalData)
    if (globalData.users.isNotEmpty) {
      filteredSchools = List.from(globalData.users);
      _loadNextUiPage();
      return;
    }

    // 2️⃣ HIVE (pincode based)
    final cached = schoolBox.values
        .where((e) => e.address.pincode == globalData.pincode)
        .toList();

    if (cached.isNotEmpty) {
      final users = cached.map((e) => e.toUser()).toList();
      globalData.users = users;
      filteredSchools = List.from(users);
      _loadNextUiPage();
      return;
    }

    // 3️⃣ NOTHING FOUND
    _hasMore = false;
  }



  /*void _loadNextUiPage() {
    if (!_hasMore) return;

    final start = _currentPage * _pageSize;

    // 🔥 NO MORE DATA
    if (start >= filteredSchools.length) {
      setState(() {
        _hasMore = false;
      });
      return;
    }

    final nextItems =
    filteredSchools.skip(start).take(_pageSize).toList();

    setState(() {
      displayedSchools.addAll(nextItems);
      _currentPage++;

      // 🔥 CHECK AGAIN AFTER ADD
      if (displayedSchools.length >= filteredSchools.length) {
        _hasMore = false;
      }
    });
  }*/
  Future<void> _loadNextUiPage() async {
    if (!mounted || _isApiLoading || !_hasMore) return;

    // ===============================
    // 🟢 NORMAL MODE → CACHE ONLY
    // ===============================
    if (!_isFilterMode) {
      final start = _currentPage * _pageSize;

      if (start >= filteredSchools.length) {
        setState(() => _hasMore = false);
        return;
      }

      final nextItems =
      filteredSchools.skip(start).take(_pageSize).toList();

      setState(() {
        displayedSchools.addAll(nextItems);
        _currentPage++;
        _hasMore = displayedSchools.length < filteredSchools.length;
      });

      return;
    }

    // ===============================
    // 🔥 FILTER MODE → API ONLY
    // ===============================
    if (lastFilterRequest == null) return;

    setState(() {
      _isApiLoading = true;
    });

    try {
      final users = await FilterSchoolService().filterSchools(
        lastFilterRequest!.copyWith(
          offset: _filterOffset,
          limit: _filterLimit,
        ),
      );

      if (!mounted) return;

      setState(() {
        displayedSchools.addAll(users);
        _filterOffset += users.length;
        _hasMore = users.length == _filterLimit;
        _isApiLoading = false;
        _showFilterLoader = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isApiLoading = false;
        _showFilterLoader = false;
      });

      debugPrint('❌ Filter pagination failed: $e');
    }
  }




  void _onLocationSelected(String selectedLocation) {
    setState(() {
      globalData.city = selectedLocation;
      _citySelectionController.text = selectedLocation;
      _filterSchools();
    });
  }

  void _navigateToFilter(String category) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: FilterComponent(
          selectedCategory: category,
          initialRequest: lastFilterRequest, // 🔥 PASS OLD FILTER
        ),
      ),
    );

    if (result != null && result is FilterSchoolRequest) {
      setState(() {
        lastFilterRequest = result.copyWith(
          primaryCategory: category,   // 🔥 store where it came from
        );
        _isFilterMode = true;

        // 🔥 HARD RESET
        filteredSchools.clear();
        displayedSchools.clear();

        _filterOffset = 0;
        _hasMore = true;
        _showFilterLoader = true;
      });

      _loadNextUiPage(); // 🔥 API CALL ONLY
    }
  }




  /*void _applyFilters(Map<String, List<String>> filters) {
    filteredSchools = globalData.users.where((user) {
      bool matches = true;

      if (filters['City'] != null) {
        matches = matches && filters['City']!.contains(user.address.city);
      }
      if (filters['Board'] != null) {
        matches = matches && filters['Board']!.contains(user.boards);
      }
      if (filters['School Type'] != null) {
        matches = matches && filters['School Type']!.contains(user.format);
      }
      if (filters['Class'] != null) {
        matches = matches && filters['Class']!.contains(user.classesOffered);
      }
      if (filters['Popular Localities'] != null) {
        matches = matches &&
            filters['Popular Localities']!.contains(user.address.area);
      }
      if (filters['Co-ed Status'] != null) {
        matches = matches && filters['Co-ed Status']!.contains(user.coedStatus);
      }
      if (filters['Language of Instruction'] != null) {
        matches = matches &&
            filters['Language of Instruction']!
                .contains(user.languagesTaught);
      }

      return matches;
    }).toList();
    _resetPagination();

    _updateDisplayedSchools();
  }*/
  void _applyFilters(Map<String, List<String>> filters) {
    if (_isFilterMode) return;
    filteredSchools = globalData.users.where((user) {
      bool matches = true;


      // 🟡 Board (user.boards = List<String>)
      if (filters['Board'] != null && filters['Board']!.isNotEmpty) {
        matches = matches &&
            filters['Board']!
                .any((b) => user.boards.toString().contains(b));

      }


      // 🟡 School Type
      if (filters['School Type'] != null &&
          filters['School Type']!.isNotEmpty) {
        matches = matches &&
            filters['School Type']!.contains(user.format);
      }

      // 🟡 Area / Locality
      if (filters['Popular Localities'] != null &&
          filters['Popular Localities']!.isNotEmpty) {
        matches = matches &&
            filters['Popular Localities']!.contains(user.address.area);
      }

      // 🟡 Co-ed Status
      if (filters['Co-ed Status'] != null &&
          filters['Co-ed Status']!.isNotEmpty) {
        matches = matches &&
            filters['Co-ed Status']!.contains(user.coedStatus);
      }

      // 🟡 Class
      if (filters['Class'] != null && filters['Class']!.isNotEmpty) {
        matches = matches &&
            filters['Class']!.any((c) =>
                user.classesOffered.toString().contains(c));
      }

// 🟡 Language
      if (filters['Language of Instruction'] != null &&
          filters['Language of Instruction']!.isNotEmpty) {
        matches = matches &&
            filters['Language of Instruction']!.any((l) =>
                user.languagesTaught.toString().contains(l));
      }


      return matches;
    }).toList();

    // 🔥 IMPORTANT: only this
    _resetPagination();
  }


  void _updateDisplayedSchools() {
    filteredSchools = filteredSchools.where((user) {
      return user.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

  }

  void _filterSchools() {
    filteredSchools = globalData.users.where((user) {
      return user.address.pincode  == globalData.pincode ;
    }).toList();

    _updateDisplayedSchools();
    _resetPagination();
  }


  void _removeFilter(String category, String value) {
    setState(() {
      activeFilters[category]?.remove(value);
      if (activeFilters[category]?.isEmpty ?? true) {
        activeFilters.remove(category);
      }
      _applyFilters(activeFilters);
    });
  }

  void _showLocationModal() async {
    String? selectedLocation = await LocationModal.show(context);

    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      setState(() {
        _citySelectionController.text = selectedLocation;
        _selectedLocation = selectedLocation;
        _onLocationSelected(selectedLocation);
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _isFilterMode = false;
      lastFilterRequest = null;

      filteredSchools.clear();
      displayedSchools.clear();

      _filterOffset = 0;
      _hasMore = true;
      _isApiLoading = false;
      _showFilterLoader = false;
    });

    // 🔄 BACK TO CACHE (LOGIN / HOME DATA)
    _loadFromCache();
  }

  bool _isCategorySelected(String category) {
    if (lastFilterRequest == null) return false;

    switch (category) {
      case 'Popular Areas':
        return lastFilterRequest!.areas.isNotEmpty;

      case 'Board':
        return lastFilterRequest!.boards.isNotEmpty;

      case 'Language of Instruction':
        return lastFilterRequest!.langTaught.isNotEmpty;

      case 'Co-ed Status':
        return lastFilterRequest!.gender.isNotEmpty;

      case 'Class':
        return lastFilterRequest!.level.isNotEmpty;

      case 'School Type':
        return lastFilterRequest!.type.isNotEmpty;


      default:
        return false;
    }
  }




  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),*/
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: GestureDetector(
          onTap: _showLocationModal,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'LOCATION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _citySelectionController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(context),

    );
  }

  // ===================== BODY ======================

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildHeader(colorScheme),
        _buildTopFilterRow(),
        _buildFilterSummaryCard(),
        Expanded( // 🔥 VERY IMPORTANT
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //_buildTypeSummaryCard(),
                const SizedBox(height: 12),

                // CONTENT AREA
                Expanded(
                  child: _buildSchoolList(),
                ),
                const SizedBox(height: 100.0,),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSchoolList() {
    // 1️⃣ Skeleton state (first load)
/*    if (showSkeleton) {
      return _buildSkeletonList();
    }*/
    if (_showFilterLoader) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => _buildSchoolCardShimmer(),
      );
    }
    // 2️⃣ Empty after filters
    if (displayedSchools.isEmpty && !_isApiLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "No schools found",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // 3️⃣ Normal list with UI pagination
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 120) {
          _loadNextUiPage(); // ✅ SAFE
        }
        return false;
      },
      child: ListView.builder(
        itemCount: displayedSchools.length +
            (displayedSchools.length ~/ 3) + // 🔥 ads every 3
            (_hasMore ? 1 : 0),

        itemBuilder: (context, index) {

          // ⏳ pagination loader at bottom
          if (_hasMore && index == displayedSchools.length + (displayedSchools.length ~/ 3)) {
            return _uiPaginationHint();
          }

          // 🟦 Native Ad after every 3 schools
          if ((index + 1) % 4 == 0) {
            return const SizedBox(
              height: 120,
              child: NativeAdWidget(),
            );
          }

          // 📚 Calculate actual school index
          final schoolIndex = index - (index ~/ 4);

          if (schoolIndex < displayedSchools.length) {
            return _buildSchoolCard(displayedSchools[schoolIndex]);
          }

          return const SizedBox();
        },
      ),

      /* child: ListView.builder(
        itemCount: displayedSchools.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayedSchools.length) {
            return _uiPaginationHint();
          }
          return _buildSchoolCard(displayedSchools[index]);
        },
      ),*/
    );
  }
  Widget _uiPaginationHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          "Loading more schools...",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildSkeletonCard();
        },
      ),
    );
  }
  Widget _buildSkeletonCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.83;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            _shimmerBox(height: 160, radius: 22),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 14, width: cardWidth * 0.6),
                  const SizedBox(height: 8),
                  _shimmerBox(height: 12, width: cardWidth * 0.4),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _shimmerBox(height: 20, width: 70),
                      const SizedBox(width: 8),
                      _shimmerBox(height: 20, width: 60),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 40)),
                      const SizedBox(width: 10),
                      Expanded(child: _shimmerBox(height: 40)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _shimmerBox({
    double height = 12,
    double width = double.infinity,
    double radius = 12,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  // BLUE HEADER (title + search)
  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedValue in $_selectedLocation',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // search bar
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: Colors.black54, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: ()
                           /* Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchPage()),
                            );*/
                           async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SearchPage()),
                              );

                              if (result != null && result is String) {
                                setState(() {
                                  searchQuery = result;
                                });

                                if (_isFilterMode) return;
                                _filterSchools();
                                // 🔥 reapply filters + pagination
                              }

                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: const Row(
                              children: const [
                                Text(
                                  'What are you looking for?',
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // yellow filter icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2A900),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:Stack(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2A900),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            if (lastFilterRequest != null) {
                              _navigateToFilter('Class');
                            } else {
                              _navigateToFilter('Class');
                            }
                          }

                      ),
                    ),
                    if (getSelectedFilterCount() > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            getSelectedFilterCount().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                )

              ),
            ],
          ),
        ],
      ),
    );
  }
  int getSelectedFilterCount() {
    if (lastFilterRequest == null) return 0;

    int count = 0;
    count += lastFilterRequest!.areas.length;
    count += lastFilterRequest!.boards.length;
    count += lastFilterRequest!.langTaught.length;

    if (lastFilterRequest!.gender.isNotEmpty) count++;
    if (lastFilterRequest!.medium.isNotEmpty) count++;
    if (lastFilterRequest!.level.isNotEmpty) count++;
    if (lastFilterRequest!.type.isNotEmpty) count++;

    return count;
  }

  List<String> getSelectedFilterLabels() {
    if (lastFilterRequest == null) return [];

    final labels = <String>[];
    labels.addAll(lastFilterRequest!.areas);
    labels.addAll(lastFilterRequest!.boards);
    labels.addAll(lastFilterRequest!.langTaught);

    if (lastFilterRequest!.gender.isNotEmpty) {
      labels.add(lastFilterRequest!.gender);
    }
    if (lastFilterRequest!.medium.isNotEmpty) {
      labels.add(lastFilterRequest!.medium);
    }
    if (lastFilterRequest!.level.isNotEmpty) {
      labels.add(lastFilterRequest!.level);
    }
    if (lastFilterRequest!.type.isNotEmpty) {
      labels.add(lastFilterRequest!.type);
    }

    return labels;
  }


  String getFilterTitle() {
    final filters = getSelectedFilterLabels();
    if (filters.isEmpty) return '';

    if (filters.length == 1) {
      return filters.first;
    }
    return '${filters.first} +${filters.length - 1} more';
  }
  Widget _buildFilterSummaryCard() {
    if (getSelectedFilterCount() == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.blue),
          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getFilterTitle(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing ${displayedSchools.length} results',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // CLEAR
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearFilter,
          ),

          // CHANGE
          TextButton(
            onPressed: () => _navigateToFilter('Class'),
            child: const Text(
              'CHANGE',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }


  // FILTER ROW (circle filter + chips)
  Widget _buildTopFilterRow() {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // round filter button
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.filter_list, size: 22),
                onPressed: () => _navigateToFilter('Class'),
              ),
            ),
            _buildFilterPill('Class'),
            const SizedBox(width: 8),
            _buildFilterPill('Board'),
            const SizedBox(width: 8),
            _buildFilterPill('Popular Areas'),
            const SizedBox(width: 8),
            _buildFilterPill('School Type'),
            const SizedBox(width: 8),
            _buildFilterPill('Co-ed Status'),
            const SizedBox(width: 8),
            _buildFilterPill('Language of Instruction'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String category) {
    final bool isActive = _isCategorySelected(category);
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => _navigateToFilter(category),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? primary : Colors.grey.shade300,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category,
              style: TextStyle(
                color: isActive ? primary : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? primary : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }




  // To keep text correct per category
  // ignore: unused_element
  Widget _filterLabel(String category) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        category,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 4),
      const Icon(Icons.keyboard_arrow_down, size: 16),
    ],
  );

  // small "Day School" summary card (white)
/*  Widget _buildTypeSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, size: 24, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Showing ${displayedSchools.length} results',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {}, // change format
            child: const Text(
              'CHANGE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  // =============== SCHOOL CARD (vertical, screenshot style) ===============

  Widget _buildSchoolCard(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = GlobalData().selectedSchools.contains(user);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image + badges
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      user.galleryImages.isNotEmpty
                          ? user.galleryImages[0]
                          : 'assets/images/dummy_image.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,

                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/dummy_image.png",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    // rating pill
                    if (user.averageRating.isNotEmpty &&
                        double.tryParse(user.averageRating) != null &&
                        double.parse(user.averageRating) > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2A900),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                double.parse(user.averageRating)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // board pill
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
                          user.boards,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Verified / Partner badges — bottom left
                    if (user.verified == 'Y' || user.partner == 'Y')
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Row(
                          children: [
                            if (user.verified == 'Y')
                              _schoolBadge(
                                icon: Icons.verified_rounded,
                                label: 'Verified',
                                color: const Color(0xFF2E7D32),
                              ),
                            if (user.verified == 'Y' && user.partner == 'Y')
                              const SizedBox(width: 6),
                            if (user.partner == 'Y')
                              _schoolBadge(
                                icon: Icons.handshake_outlined,
                                label: 'Partner',
                                color: Color(0xFFF2A900),
                              ),
                          ],
                        ),
                      ),
                    // heart
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: IconButton(
                        icon: Icon(
                          ShortlistHelper.isLiked(user)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: ShortlistHelper.isLiked(user)
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () async {

                          final prefs = await SharedPreferences.getInstance();
                          final isLoggedIn = prefs.getBool('isLoggedIn')  ?? false; ;
                          final isGuestUser = prefs.getBool('isGuestUser')   ?? false;;

                          if (isLoggedIn == false || isGuestUser == true) {
                            _showLoginPromptBottomSheet(context, user);
                            return;
                          }

                          final isLiked = ShortlistHelper.isLiked(user);

                          if (isLiked) {



                            // ❤️ REMOVE (UI first)
                            ShortlistHelper.remove(user.id);

                            setState(() {}); // instant UI update

                            // API call (background)
                            RemoveShortlistedSchoolService().removeShortlistedSchool(
                              schoolId: user.id,
                              shortListedBy: mobileNumber,
                            );
                          } else {
                            // ❤️ ADD (UI first)
                            ShortlistHelper.add(user.id);

                            setState(() {}); // instant UI update

                            // API call (background)
                            shortlistApiCall.shortList(
                              schoolId: user.id,
                              schoolName: user.name,
                              pinCode: user.address.pincode,
                              areaName: user.address.area,
                              state: user.address.state,
                              district: user.address.district,
                              city: user.address.city.name,
                              mobileNumber: mobileNumber,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // text section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${user.address.area}, ${user.address.city.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user.classesOffered,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user.boards,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // compare + button row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        GlobalData().toggleCompare(user);
                        if (GlobalData().selectedSchools.length == 2) {
                          bottomNavKey.currentState?.goToTab(1);
                        }
                      });
                    },
                  ),
                  const Text(
                    'Compare',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 160,
                    child: AppElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SchoolDetailsPage(user: user),
                          ),
                        );
                      },
                      text: 'View Details',
                      buttonSize: ButtonSize.small,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _schoolBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
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
Widget _buildSchoolCardShimmer() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 190, radius: 18), // image
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(height: 16, width: 220),
                const SizedBox(height: 8),
                _shimmerBox(height: 12, width: 160),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _shimmerBox(height: 22, width: 90),
                    const SizedBox(width: 8),
                    _shimmerBox(height: 22, width: 70),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _shimmerBox(height: 40)),
                    const SizedBox(width: 12),
                    Expanded(child: _shimmerBox(height: 40)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _shimmerBox({
  double height = 12,
  double width = double.infinity,
  double radius = 12,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
void _showLoginPromptBottomSheet(BuildContext context, User user) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Heart Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              "Sign in to Save Schools",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Create an account to save your favorite schools and access them anytime across all devices.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Benefits section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    Icons.bookmark_added_outlined,
                    "Save unlimited schools",
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    Icons.compare_arrows_outlined,
                    "Compare schools easily",
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    Icons.notifications_active_outlined,
                    "Get admission updates",
                    theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sign In Button
            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet

                  // Login page par le jao
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Sign In to Continue",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Maybe Later",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget _buildBenefitRow(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    ],
  );
}