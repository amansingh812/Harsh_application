import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/apis/search_schools_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_scout/screens/details/school_details_page.dart';
import '../../global/global_data.dart';
import '../../apis/api_service.dart';
import '../../repository/mapper/search_school_mapper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String city = GlobalData().city;
  String _selectedValue = 'Day School';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // 🔥 Add FocusNode
  List<User> filteredSchools = [];
  List<User> _results = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isSearchFocused = false; // 🔥 Track focus

  Timer? _debounce;
  late AnimationController _animationController;

  final List<String> recentSearches = [
    'CBSE Schools',
    'IB Schools',
    'Montessori Schools',
  ];

  final List<Map<String, dynamic>> popularSearches = [
    {'title': 'Top CBSE Schools', 'count': '2450+', 'icon': Icons.school},
    {'title': 'IB Curriculum', 'count': '380+', 'icon': Icons.school_sharp},
    {'title': 'Boarding Schools', 'count': '156+', 'icon': Icons.home},
    {'title': 'Play Schools', 'count': '890+', 'icon': Icons.child_care},
  ];

  final List<String> searchByOptions = [
    'School',
    'Area',
    'City',
    'Pincode',
    'Board',
  ];
  int _selectedSearchByIndex = 0;
  String _animatedHint = 'School';
  Timer? _hintTimer;
  int _searchByIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedValue = GlobalData().selectedSchoolType;
    _searchController.addListener(_onSearchChanged);

    // 🔥 Listen to focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
    _startHintAnimation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose(); // 🔥 Dispose FocusNode
    _hintTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startHintAnimation() {
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _searchByIndex = (_searchByIndex + 1) % searchByOptions.length;
          _animatedHint = searchByOptions[_searchByIndex];
        });
      }
    });
  }

  void _filterSchools(String type) {
    setState(() {
      filteredSchools = GlobalData().users.where((school) {
        return school.format == type;
      }).toList();
    });
  }

  Map<String, String> _buildSearchFields(String query) {
    return {
      'schoolName': _selectedSearchByIndex == 0 ? query : '',
      'area': _selectedSearchByIndex == 1 ? query : '',
      'city': _selectedSearchByIndex == 2 ? query : '',
      'pinCode': _selectedSearchByIndex == 3 ? query : '',
      'board': _selectedSearchByIndex == 4 ? query : '',
    };
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _debounce?.cancel();

    if (query.length < 3) {
      setState(() {
        _results.clear();
        _isSearching = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchSchools(query);
    });
  }

  Future<void> _searchSchools(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fields = _buildSearchFields(query);

      final users = await SearchSchoolsMapper().searchAsUsers(
        schoolName: fields['schoolName']!,
        area: fields['area']!,
        city: fields['city']!,
        pinCode: fields['pinCode']!,
        board: fields['board']!,
      );

      if (!mounted) return;

      setState(() {
        _results = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _results.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToSchoolDetails(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolDetailsPage(user: user),
      ),
    );
  }

  Widget _buildSearchShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => _buildSearchShimmer(),
      );
    }

    if (_results.isEmpty && _isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            children: [
              Icon(Icons.school_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No schools found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final user = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildSchoolResultCard(user),
        );
      },
    );
  }

  Widget _buildSchoolResultCard(User user) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToSchoolDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF002D72).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Color(0xFF002D72),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.address.area,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSearchUi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF002D72).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF002D72).withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16,
                  color: const Color(0xFF002D72).withOpacity(0.7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Type at least 3 letters to search',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF002D72).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        _buildSearchBySelector(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchBySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH BY',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchByOptions.map((item) {
            final index = searchByOptions.indexOf(item);
            final isSelected = index == _selectedSearchByIndex;

            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF002D72),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF002D72)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedSearchByIndex = index;
                });

                final query = _searchController.text.trim();
                if (query.length >= 3) {
                  _searchSchools(query);
                } else {
                  setState(() {
                    _results.clear();
                    _isSearching = false;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final global = GlobalData();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF002D72),
          statusBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF002D72),
        title: Text(
          "Search Schools",
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School Type Dropdown
              /*Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "School Type",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: global.selectedSchoolType,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Icon(Icons.expand_more,
                            color: Color(0xFF002D72)),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            global.updateSelectedSchoolType(newValue!);
                            _filterSchools(newValue);
                          });
                        },
                        items: [
                          'Day School',
                          'Boarding School',
                          'Day Boarding School',
                          'Play School',
                        ]
                            .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text("$value in ${global.city}"),
                        ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),*/

              const SizedBox(height: 16),

              // 🔥 Search Bar with Vertical Spin Animation
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: const Color(0xFF002D72), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode, // 🔥 Add FocusNode
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '',
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                          // 🔥 Show only when empty AND not focused
                          if (_searchController.text.isEmpty && !_isSearchFocused)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 🔒 Static "Search by " text
                                      const Text(
                                        'Search by ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      // 🔄 Animated rotating word with VERTICAL slide
                                      ClipRect(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 500),
                                          switchInCurve: Curves.easeInOut,
                                          switchOutCurve: Curves.easeInOut,
                                          transitionBuilder: (child, animation) {
                                            // 🎯 VERTICAL SLIDE (top to bottom)
                                            final offsetAnimation = Tween<Offset>(
                                              begin: const Offset(0, -1.0), // From top
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOutCubic,
                                            ));

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          layoutBuilder: (currentChild, previousChildren) {
                                            return Stack(
                                              alignment: Alignment.centerLeft,
                                              children: [
                                                ...previousChildren,
                                                if (currentChild != null) currentChild,
                                              ],
                                            );
                                          },
                                          child: Text(
                                            _animatedHint,
                                            key: ValueKey(_animatedHint),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF002D72),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
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
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF002D72), size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results.clear();
                            _isSearching = false;
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results or Default UI
              _isSearching
                  ? _buildSearchResults()
                  : _buildDefaultSearchUi(),
            ],
          ),
        ),
      ),
    );
  }
}