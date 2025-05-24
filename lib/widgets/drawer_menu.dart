import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  final List<String> savedRegions;
  final List<String> recentRegions;
  final Function(String) onRegionSelected;
  final Function(String) onRegionAdded;
  final Function(String) onRegionRemoved;
  final Set<String> pinnedRegions;

  const DrawerMenu({
    super.key,
    required this.savedRegions,
    required this.recentRegions,
    required this.onRegionSelected,
    required this.onRegionAdded,
    required this.onRegionRemoved,
    required this.pinnedRegions,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final TextEditingController _controller = TextEditingController();

  void _handleAddRegion() {
    final input = _controller.text.trim();
    if (input.isNotEmpty && !widget.savedRegions.contains(input)) {
      widget.onRegionAdded(input);
      _controller.clear();
    }
  }

  void _togglePin(String region) {
    setState(() {
      if (widget.pinnedRegions.contains(region)) {
        widget.pinnedRegions.remove(region);
      } else {
        widget.pinnedRegions.add(region);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pinned = widget.savedRegions.where((r) => widget.pinnedRegions.contains(r)).toList();
    final others = widget.savedRegions.where((r) => !widget.pinnedRegions.contains(r)).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📍 지역 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: '지역 이름 입력',
                        hintText: '예: 서울, 부산...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _handleAddRegion,
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),

            // 📁 즐겨찾기 구역
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📁 지역 즐겨찾기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: [
                  ...pinned.map((region) => _buildRegionTile(region, pinned: true)),
                  ...others.map((region) => _buildRegionTile(region)),
                ],
              ),
            ),

            // 🕓 최근 방문 지역 구역
            if (widget.recentRegions.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🕓 최근 방문 지역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...widget.recentRegions.map((region) => ListTile(
                title: Text(region),
                leading: const Icon(Icons.history),
                onTap: () {
                  widget.onRegionSelected(region);
                  Navigator.pop(context);
                },
              )),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRegionTile(String region, {bool pinned = false}) {
    return ListTile(
      title: Text(region),
      leading: const Icon(Icons.location_on),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => _togglePin(region),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => widget.onRegionRemoved(region),
          ),
        ],
      ),
      onTap: () {
        widget.onRegionSelected(region);
        Navigator.pop(context);
      },
    );
  }
}
