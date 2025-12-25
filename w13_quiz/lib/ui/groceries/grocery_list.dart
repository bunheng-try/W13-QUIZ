import 'package:flutter/material.dart';
import '../../data/mock_grocery_repository.dart';
import '../../models/grocery.dart';
import 'grocery_form.dart';
import "grocery_pages.dart" as pages;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  int _currentIndex = 1;
  final Set<String> _selectedIds = {};

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = dummyGroceryItems.removeAt(oldIndex);
      dummyGroceryItems.insert(newIndex, item);
    });
  }

  bool get _selectionMode => _selectedIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _selectedIds.add(id);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _deleteSelected() {
    setState(() {
      dummyGroceryItems.removeWhere((g) => _selectedIds.contains(g.id));
      _selectedIds.clear();
    });
  }

  void onCreate() async {
    // Navigate to the form screen using the Navigator push
    Grocery? newGrocery = await Navigator.push<Grocery>(
      context,
      MaterialPageRoute(builder: (context) => const GroceryForm()),
    );
    if (newGrocery != null) {
      setState(() {
        dummyGroceryItems.add(newGrocery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (dummyGroceryItems.isNotEmpty) {
      //  Display groceries with an Item builder and  LIst Tile
      content = IndexedStack(
        index: _currentIndex,
        children: [
          // When in selection mode we disable reordering and show checkboxes
          if (!_selectionMode)
            ReorderableListView(
              onReorder: _onReorder,
              children: [
                for (final g in dummyGroceryItems)
                  ListTile(
                    key: ValueKey(g.id),
                    leading: GestureDetector(
                      onLongPress: () => _enterSelection(g.id),
                      child: Container(width: 15, height: 15, color: g.category.color),
                    ),
                    title: Text(g.name),
                    trailing: Text(g.quantity.toString()),
                    onTap: () {},
                  ),
              ],
            )
          else
            ListView.builder(
              itemCount: dummyGroceryItems.length,
              itemBuilder: (context, index) {
                final g = dummyGroceryItems[index];
                final selected = _selectedIds.contains(g.id);
                return ListTile(
                  leading: Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleSelection(g.id),
                  ),
                  title: Row(
                    children: [
                      Container(width: 15, height: 15, color: g.category.color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(g.name)),
                    ],
                  ),
                  subtitle: Text(g.category.name),
                  trailing: Text(g.quantity.toString()),
                  onTap: () => _toggleSelection(g.id),
                );
              },
            ),

          pages.SearchBar(),
        ],
      );
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: "Groceries",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        ],
      ),
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: onCreate, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}

class GroceryTile extends StatelessWidget {
  const GroceryTile({super.key, required this.grocery});

  final Grocery grocery;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 15, height: 15, color: grocery.category.color),
      title: Text(grocery.name),
      trailing: Text(grocery.quantity.toString()),
    );
  }
}