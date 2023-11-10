import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../models/shopping_list_provider.dart';
import 'add_item_page.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  void _addItem(Product item) {
    context.read<ShoppingListProvider>().addItem(item);
  }

  @override
  void initState() {
    super.initState();
    context.read<ShoppingListProvider>().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => const PreferencesPage());
            },
            icon: const Icon(Icons.tune),
          )
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, state, child) {
          return state.isBusy
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text(state.error!))
                  : ListView.builder(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final item = state.products[index];
                        return ListTile(
                          leading: Icon(
                            item.category.icon,
                            color: Colors.blue,
                          ),
                          title: Text(item.name),
                          subtitle:
                              Text('${item.category.name}- ${item.quantity}'),
                          trailing: Checkbox(
                            value: item.isBought,
                            onChanged: (value) {
                              state.itemBoughtChanged(item);
                            },
                          ),
                        );
                      },
                    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add item page
          final item =
              await Navigator.of(context).push<Product>(MaterialPageRoute(
            builder: (context) => const AddItemPage(),
          ));
          if (item != null) {
            _addItem(item);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, model, child) => SimpleDialog(
        title: const Text('Preferences'),
        children: [
          SwitchListTile(
            value: model.groupByCategory,
            onChanged: (value) {
              setState(() => model.groupByCategoryChanged(value));
            },
            title: const Text('Group by Category'),
          ),
          SwitchListTile(
            value: model.moveBoughtDown,
            onChanged: (value) {
              setState(() => model.moveBoughtDownChanged(value));
            },
            title: const Text('Move Bought Items Down'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          )
        ],
      ),
    );
  }
}
