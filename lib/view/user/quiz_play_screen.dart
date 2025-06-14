import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/model/question.dart';
import 'package:myapp/model/quiz.dart';
import 'package:myapp/theme/theme.dart';
import 'package:myapp/view/user/quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  Map<int, int?> _selectedAnswers = {};
  int _totalMinutes = 0;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _totalMinutes = widget.quiz.timtLimit;
    _remainingMinutes = _totalMinutes;
    _remainingSeconds = 0;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          if (_remainingMinutes > 0) {
            _remainingMinutes--;
            _remainingSeconds = 59;
          } else {
            _timer?.cancel();
            _completeQuiz();
          }
        }
      });
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = optionIndex;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    _timer?.cancel();
    int correctAnswers = _calculateScore();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              quiz: widget.quiz,
              totalQuestions: widget.quiz.questions.length,
              correctAnswers: correctAnswers,
              selectedAnswers: _selectedAnswers,
            ),
      ),
    );
  }

  int _calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final selectedAnswer = _selectedAnswers[i];
      if (selectedAnswer != null &&
          selectedAnswer == widget.quiz.questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  Color _getTimerColor() {
    double timeProgress =
        1 -
        ((_remainingMinutes * 60 + _remainingSeconds) / (_totalMinutes * 60));
    if (timeProgress < 0.4) return Colors.green;
    if (timeProgress < 0.6) return Colors.orange;
    if (timeProgress < 0.8) return Colors.deepOrange;
    return Colors.redAccent;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.textPrimryColor,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: CircularProgressIndicator(
                              value:
                                  (_remainingMinutes * 60 + _remainingSeconds) /
                                  (_totalMinutes * 60),
                              strokeWidth: 5,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTimerColor(),
                              ),
                            ),
                          ),
                          Text(
                            '$_remainingMinutes:${_remainingSeconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getTimerColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end:
                          (_currentQuestionIndex + 1) /
                          widget.quiz.questions.length,
                    ),
                    duration: Duration(milliseconds: 300),
                    builder: (context, progress, child) {
                      return LinearProgressIndicator(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 6,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.quiz.questions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  return _buildQuestionCard(question, index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                question.text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimryColor,
                ),
              ),
              SizedBox(height: 24),
              ...question.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final option = entry.value;
                final isSelected = _selectedAnswers[index] == optionIndex;
                final isCorrect =
                    _selectedAnswers[index] == question.correctOptionIndex;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedContainer(
                    duration: Duration(microseconds: 300),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? isCorrect
                                  ? AppTheme.secondaryColor.withOpacity(0.1)
                                  : Colors.redAccent.withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? isCorrect
                                    ? AppTheme.secondaryColor
                                    : Colors.redAccent
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      onTap:
                          _selectedAnswers[index] == null
                              ? () => _selectAnswer(optionIndex)
                              : null,
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
                                  ? isCorrect
                                      ? AppTheme.secondaryColor
                                      : Colors.redAccent
                                  : _selectedAnswers[index] != null
                                  ? Colors.grey.shade500
                                  : AppTheme.textPrimryColor,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? isCorrect
                                  ? Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.secondaryColor,
                                  )
                                  : Icon(Icons.close, color: Colors.redAccent)
                              : null,
                    ),
                  ),
                );
              }),
              // Spacer(),
              // SizedBox(
              //   width: double.infinity,
              //   height: 55,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       _selectedAnswers[index] != null ? _nextQuestion() : null;
              //     },
              //     child: Text(
              //       index == widget.quiz.questions.length - 1
              //           ? 'Finish Quiz'
              //           : 'Next Question',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: 300))
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildFloatingActionButton() {
    final isLastQuestion =
        _currentQuestionIndex == widget.quiz.questions.length - 1;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: FloatingActionButton.extended(
        onPressed:
            _selectedAnswers[_currentQuestionIndex] != null
                ? _nextQuestion
                : null,
        label: Text(
          isLastQuestion ? 'Finish Quiz' : 'Next Question',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            _selectedAnswers[_currentQuestionIndex] != null
                ? AppTheme.primaryColor
                : Colors.grey,
      ),
    );
  }
}
