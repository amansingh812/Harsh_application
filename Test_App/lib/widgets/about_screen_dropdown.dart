import 'package:flutter/material.dart';

class AboutScreenDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const AboutScreenDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  State<AboutScreenDropdown> createState() =>
      _AboutScreenDropdownState();
}

class _AboutScreenDropdownState
    extends State<AboutScreenDropdown> {
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SEARCH FIELD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label.toLowerCase()}...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filteredItems = widget.items
                              .where((e) => e
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (_, index) {
                        final item = filteredItems[index];
                        final isSelected = item == widget.selectedItem;

                        return InkWell(
                          onTap: () {
                            widget.onChanged(item);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            color: isSelected
                                ? const Color(0xFFFFF4DE)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Color(0xFF1F3C88),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openBottomSheet,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE3E7F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.selectedItem ?? widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.selectedItem == null
                      ? Colors.grey
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
