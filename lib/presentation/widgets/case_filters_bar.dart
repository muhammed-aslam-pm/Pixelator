import 'package:flutter/material.dart';

class CaseFiltersBar extends StatefulWidget {
  final String initialSearchQuery;
  final int? selectedPriority;
  final Function(String) onSearchChanged;
  final Function(String?) onPriorityChanged;
  final Function() onFiltersTap;

  const CaseFiltersBar({
    super.key,
    this.initialSearchQuery = '',
    this.selectedPriority,
    required this.onSearchChanged,
    required this.onPriorityChanged,
    required this.onFiltersTap,
  });

  @override
  State<CaseFiltersBar> createState() => _CaseFiltersBarState();
}

class _CaseFiltersBarState extends State<CaseFiltersBar> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  String _getPriorityText() {
    if (widget.selectedPriority == null) {
      return 'All Priorities';
    }
    switch (widget.selectedPriority) {
      case 1:
        return 'Critical';
      case 2:
        return 'High';
      case 3:
        return 'Medium';
      case 4:
        return 'Low';
      case 5:
        return 'Very Low';
      default:
        return 'Priority';
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
  }

  @override
  void didUpdateWidget(CaseFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearchQuery != widget.initialSearchQuery) {
      _searchController.text = widget.initialSearchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Mobile: Stack vertically
      return Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search cases...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF2D3748),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4299E1),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
              widget.onSearchChanged(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _searchFocusNode.unfocus();
                  },
                  child: PopupMenuButton<String?>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: const Color(0xFF2D3748),
                    onOpened: () {
                      _searchFocusNode.unfocus();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('All Priorities', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: '1',
                        child: Text('Critical', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: '2',
                        child: Text('High', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: '3',
                        child: Text('Medium', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: '4',
                        child: Text('Low', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: '5',
                        child: Text('Very Low', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onSelected: widget.onPriorityChanged,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getPriorityText(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: widget.onFiltersTap,
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3748),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    // Desktop: Horizontal row
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search cases by name, number, hospital, or patient ID...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF2D3748),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4299E1),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
              widget.onSearchChanged(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            _searchFocusNode.unfocus();
          },
          child: PopupMenuButton<String?>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFF2D3748),
            onOpened: () {
              _searchFocusNode.unfocus();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Priorities', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: '1',
                child: Text('Critical', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: '2',
                child: Text('High', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: '3',
                child: Text('Medium', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: '4',
                child: Text('Low', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: '5',
                child: Text('Very Low', style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: widget.onPriorityChanged,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getPriorityText(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: widget.onFiltersTap,
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filters'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D3748),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
