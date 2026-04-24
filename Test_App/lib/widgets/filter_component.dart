import 'package:flutter/material.dart';
import '../global/global_data.dart';
import '../model/filter_schools_request.dart';

class FilterComponent extends StatefulWidget {
  final String selectedCategory;
  final FilterSchoolRequest? initialRequest;

  const FilterComponent({
    required this.selectedCategory,
    this.initialRequest,
    Key? key,
  }) : super(key: key);

  @override
  State<FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  late String selectedCategory;

  late Map<String, List<String>> filterOptions;
  late Map<String, List<String>> selectedFilters;
  String areaSearchQuery = '';


  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;

    filterOptions = {
      "Class": GlobalData().getCourseNames(),
      "Board": GlobalData().getBoards(),
      "Popular Areas": const [],
      "School Type": GlobalData().getSchoolTypeNames(),
      "Co-ed Status": GlobalData().getCoEdStatus(),
      "Language of Instruction": GlobalData().getLanguages(),
    };

    selectedFilters = {
      for (final k in filterOptions.keys) k: []
    };

// 🔥 PREFILL FROM LAST FILTER
    if (widget.initialRequest != null) {
      final r = widget.initialRequest!;

      // Multi-select
      selectedFilters["Popular Areas"] = [...r.areas];
      selectedFilters["Board"] = [...r.boards];

      // Language + Medium (no duplicates)
      final langSet = <String>{
        ...r.langTaught,
        if (r.medium.isNotEmpty) r.medium,
      };
      selectedFilters["Language of Instruction"] = langSet.toList();

      // Single-select
      if (r.gender.isNotEmpty) {
        selectedFilters["Co-ed Status"] = [r.gender];
      }
      if (r.level.isNotEmpty) {
        selectedFilters["Class"] = [r.level];
      }
      if (r.type.isNotEmpty) {
        selectedFilters["School Type"] = [r.type];
      }
    }

  }

  void toggleOption(String category, String option) {
    setState(() {
      final list = selectedFilters[category]!;

      final isSingleSelect = category == "Class" ||
          category == "School Type" ||
          category == "Co-ed Status";

      if (isSingleSelect) {
        if (list.contains(option)) {
          // 🔥 tap again → unselect
          list.clear();
        } else {
          // 🔥 select new → replace
          list
            ..clear()
            ..add(option);
        }
      } else {
        // Multi select (Board, Areas, Language etc)
        list.contains(option) ? list.remove(option) : list.add(option);
      }
    });
  }



  int get totalSelectedCount =>
      selectedFilters.values.fold(0, (sum, l) => sum + l.length);

  void submit() {
    final request = FilterSchoolRequest(
      city: GlobalData().city,
      areas: selectedFilters["Popular Areas"]!,
      boards: selectedFilters["Board"]!,
      langTaught: selectedFilters["Language of Instruction"]!,
      gender: selectedFilters["Co-ed Status"]!.isNotEmpty
          ? selectedFilters["Co-ed Status"]!.first
          : "",
      medium: "",
      classes: selectedFilters["Class"]!,
      type: selectedFilters["School Type"]!.isNotEmpty
          ? selectedFilters["School Type"]!.first
          : "",
      academicSession:'',
      level:'',

      limit: 20,
      offset: 0, primaryCategory: '',
    );

    Navigator.pop(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _header(theme),
          Expanded(child: _body(theme)),
          _submitBar(theme),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          const Text(
            "Filters",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          const Spacer(),

          // 🔥 CLEAR BUTTON (only if something selected)
          if (totalSelectedCount > 0)
            TextButton(
              onPressed: clearAllFilters,
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _leftCategories(ThemeData theme) {
    return Container(
      width: 140,
      color: const Color(0xFFF4F6FB),
      child: ListView(
        children: filterOptions.keys.map((cat) {
          final selected = cat == selectedCategory;
          final count = selectedFilters[cat]!.length;

          return InkWell(
            onTap: () {
              setState(() {
                selectedCategory = cat;

                // 🔥 area change hote hi search reset
                if (cat != "Popular Areas") {
                  areaSearchQuery = '';
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                border: selected
                    ? Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 5,
                  ),
                )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(cat)),
                  if (count > 0)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _body(ThemeData theme) {
    List<String> options;

    if (selectedCategory == "Popular Areas") {

      options = [...GlobalData().areasForSelectedCity];

      // 🔥 Alphabetical sort
      options.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      // 🔍 Search filter
      if (areaSearchQuery.isNotEmpty) {
        options = options
            .where((e) =>
            e.toLowerCase().contains(areaSearchQuery.toLowerCase()))
            .toList();
      }
    } else {
      options = filterOptions[selectedCategory]!;
    }

    return Row(
      children: [
        _leftCategories(theme),
        Expanded(
          child: Column(
            children: [
              // 🔍 SEARCH BAR (sirf Popular Areas me)
              if (selectedCategory == "Popular Areas")
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => areaSearchQuery = v);
                    },
                    decoration: InputDecoration(
                      hintText: "Search areas",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // OPTIONS LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: options.map((opt) {
                    final checked =
                    selectedFilters[selectedCategory]!.contains(opt);

                    return InkWell(
                      onTap: () => toggleOption(selectedCategory, opt),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: checked
                              ? theme.colorScheme.primary.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: checked
                                ? theme.colorScheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(opt)),
                            Icon(
                              checked
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: checked
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  void clearAllFilters() {
    setState(() {
      for (final key in selectedFilters.keys) {
        selectedFilters[key] = [];
      }
    });
  }

  Widget _submitBar(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: totalSelectedCount > 0 ? submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Submit ($totalSelectedCount)",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
