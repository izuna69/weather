import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  final List<String> savedRegions;
  final Function(String) onRegionSelected;
  final Function(String) onRegionAdded;

  const DrawerMenu({
    super.key,
    required this.savedRegions,
    required this.onRegionSelected,
    required this.onRegionAdded,
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

  @override
  Widget build(BuildContext context) {
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

            // 📁 지역 즐겨찾기 제목
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
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.savedRegions.length,
                itemBuilder: (context, index) {
                  final region = widget.savedRegions[index];
                  return ListTile(
                    title: Text(region),
                    leading: const Icon(Icons.location_on),
                    onTap: () {
                      widget.onRegionSelected(region);
                      Navigator.pop(context); // 드로어 닫기
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
