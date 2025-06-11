import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ManageQuizesScreen extends StatefulWidget {
  const ManageQuizesScreen({super.key});

  @override
  State<ManageQuizesScreen> createState() => _ManageQuizesScreenState();
}

class _ManageQuizesScreenState extends State<ManageQuizesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manages Quizes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AddQuizesScreen()),
              // );
            },
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
