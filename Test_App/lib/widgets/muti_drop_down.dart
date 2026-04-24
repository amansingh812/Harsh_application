import 'package:flutter/material.dart';

class MutiDropDown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  const MutiDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<MutiDropDown> createState() => _MutiDropDownState();
}

class _MutiDropDownState extends State<MutiDropDown> {
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _openBottomSheet() {
    searchController.clear();
    filteredItems = widget.items;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SEARCH
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
                              .where((e) =>
                              e.toLowerCase().contains(value.toLowerCase()))
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
                        final isSelected =
                        widget.selectedItems.contains(item);

                        return InkWell(
                          onTap: () {
                            final list = [...widget.selectedItems];

                            if (isSelected) {
                              list.remove(item);
                            } else {
                              list.add(item);
                            }

                            widget.onChanged(list);
                            setModalState(() {});
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
                                  const Icon(Icons.check,
                                      color: Color(0xFF1F3C88)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3C88),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text("Done"),
                      ),
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
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE3E7F2)),
        ),
        child: widget.selectedItems.isEmpty
            ? Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey),
          ],
        )
            : Wrap(
          spacing: 8,
          runSpacing: 6,
          children: widget.selectedItems
              .map((e) => Chip(
            label: Text(e),
            backgroundColor:const Color(0xFFf2a900),
            deleteIcon:
            const Icon(Icons.close, size: 16),
            onDeleted: () {
              final list = [...widget.selectedItems];
              list.remove(e);
              widget.onChanged(list);
              setState(() {});
            },
          ))
              .toList(),
        ),
      ),
    );
  }
}
