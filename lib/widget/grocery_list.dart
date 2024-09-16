import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _grocerItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-5c18f-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    try {
      final response = await http.get(url);
      // if (response.statusCode <= 400) {
      //   setState(() {
      //     _error = 'Failed to fetch data. Please try again later.';
      //   });
      //   return;
      // }

      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value["category"])
            .value;
        _loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _grocerItems = _loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Somthing went wrong! Please try again later';
      });
    }
  }

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

  void _removeItem(GroceryItem item) async {
    final index = _grocerItems.indexOf(item);
    setState(() {
      _grocerItems.remove(item);
    });
    final url = Uri.https(
        'flutter-prep-5c18f-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json');
    http.delete(url);

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _grocerItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Add new Items'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_grocerItems.isNotEmpty) {
      content = ListView.builder(
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
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

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
      body: content,
    );
  }
}
