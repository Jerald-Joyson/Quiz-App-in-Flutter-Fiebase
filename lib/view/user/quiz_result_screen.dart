import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/model/quiz.dart';
import 'package:myapp/theme/theme.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, int?> selectedAnswers;
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),
      ],
    ),
  ).animate().scale(
    duration: Duration(microseconds: 400),
    delay: Duration(milliseconds: 300),
  );
}

Widget _buildAnswerRow(String label, String answer, Color answerColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondaryColor,
        ),
      ),
      SizedBox(height: 4),
      Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: answerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          answer,
          style: TextStyle(color: answerColor, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  IconData _getPerformanceIcon(double score) {
    if (score >= 0.9) return Icons.emoji_events;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    if (score >= 0.4) return Icons.trending_up;
    return Icons.refresh;
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 0.9) return "Outstanding!";
    if (score >= 0.8) return "Great Job!";
    if (score >= 0.6) return "Good Effort!";
    if (score >= 0.4) return "Keep Practicing!";
    return "Try Again";
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.correctAnswers / widget.totalQuestions;
    final scorePercentage = (score * 100).round();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        Text(
                          "Quiz Result",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 15,
                          animation: true,
                          animationDuration: 1500,
                          percent: score,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${scorePercentage}%',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${(score * 100).toInt()}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ).animate().scale(
                    delay: Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPerformanceIcon(score),
                          color: _getScoreColor(score),
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getPerformanceMessage(score),
                          style: TextStyle(
                            color: _getScoreColor(score),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    begin: 0.3,
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Correct",
                      widget.correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "Incorrect",
                      (widget.totalQuestions - widget.correctAnswers)
                          .toString(),
                      Icons.cancel,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Detailed Analysis",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...widget.quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final selectedAnswer = widget.selectedAnswers[index];
                    final isCorrect =
                        selectedAnswer != null &&
                        selectedAnswer == question.correctOptionIndex;
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.close,
                              color:
                                  isCorrect ? Colors.green : Colors.redAccent,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Question ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimryColor,
                            ),
                          ),
                          subtitle: Text(
                            question.text,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                right: 5,
                                left: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.text,
                                    style: TextStyle(
                                      color: AppTheme.textPrimryColor,
                                      fontSize: 18,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20),
                                  _buildAnswerRow(
                                    "Your Answer: ",
                                    selectedAnswer != null
                                        ? question.options[selectedAnswer]
                                        : "Not Answered",
                                    isCorrect ? Colors.green : Colors.redAccent,
                                  ),
                                  SizedBox(height: 12),
                                  _buildAnswerRow(
                                    "Correct Answer: ",
                                    question.options[question
                                        .correctOptionIndex],
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideX(
                      begin: 0.3,
                      duration: Duration(microseconds: 300),
                      delay: Duration(milliseconds: 100 * index),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                      ),
                      icon: Icon(Icons.refresh, size: 24, color: Colors.white),
                      label: Text(
                        "Try Again",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
