import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _grocerItems = [];
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _grocerItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _grocerItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _grocerItems.isEmpty
          ? const Center(
              child: Text('Add new Items'),
            )
          : ListView.builder(
              itemCount: _grocerItems.length,
              itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeItem(_grocerItems[index]);
                },
                key: ValueKey(_grocerItems[index].id),
                child: ListTile(
                  title: Text(_grocerItems[index].name),
                  leading: Container(
                    height: 24,
                    width: 24,
                    color: _grocerItems[index].category.color,
                  ),
                  trailing: Text(_grocerItems[index].quantity.toString()),
                ),
              ),
            ),
    );
  }
}
