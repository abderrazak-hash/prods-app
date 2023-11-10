import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../models/shopping_list_provider.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  bool _nameValid = false;
  int _quantity = 1;

  Category? _selectedCategory;
  late Future<void> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = context.read<ShoppingListProvider>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<void>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else {
                    return Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextFormField(
                                  controller: _itemNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Item Name',
                                    hintText: 'Enter Item Name e.g. Tea Bags',
                                    border: const OutlineInputBorder(),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.emoji_food_beverage),
                                    suffixIcon: _nameValid
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : null,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _nameValid =
                                          _formKey.currentState!.validate();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.length < 3) {
                                      return 'Please add an Item Name at least 3 characters';
                                    }
                                    return null;
                                  }),
                              DropdownButtonFormField<Category>(
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    helperText: 'Please select a category',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedCategory,
                                  items: context
                                      .read<ShoppingListProvider>()
                                      .categories
                                      .map<DropdownMenuItem<Category>>(
                                          (Category value) {
                                    return DropdownMenuItem<Category>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a category';
                                    }
                                    return null;
                                  }),
                              TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: _quantity.toString(),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        int.tryParse(value) == null ||
                                        int.parse(value) <= 0) {
                                      return 'Quantity must be a number greater than 0';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _quantity = int.parse(value!);
                                  }),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
// Add item to shopping list
                                    _formKey.currentState!.save();
                                    Navigator.of(context).pop(Product(
                                      id: DateTime.now().millisecondsSinceEpoch,
                                      name: _itemNameController.text,
                                      category: _selectedCategory!,
                                      quantity: _quantity,
                                    ));
                                  }
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add Item'),
                              ),
                            ]));
                  }
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
