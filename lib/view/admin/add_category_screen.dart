import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/model/category.dart';
import 'package:myapp/theme/theme.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.category != null) {
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await _firestore
            .collection('categories')
            .doc(widget.category!.id)
            .update(updatedCategory.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        await _firestore
            .collection('categories')
            .add(
              Category(
                id: _firestore.collection('categories').doc().id,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: DateTime.now(),
              ).toMap(),
            );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Category added successfully')));
      }
      Navigator.of(context).pop();
    } catch (e) {
      print("error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving category')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Discard changes?'),
                  content: Text(
                    'Are you sure you want to discard your changes?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Discard',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.category != null ? 'Edit Category' : 'Add Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimryColor,
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    "Create new category for organizing your quizes.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      fillColor: Colors.white,
                      labelText: 'Category Name',
                      hintText: "Enter category name",
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter category name';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'Description',
                      hintText: "Enter category description",
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                widget.category != null
                                    ? 'Update Category'
                                    : 'Add Category',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
