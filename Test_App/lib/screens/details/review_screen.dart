import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:school_scout/apis/feedback_service.dart';
import 'package:school_scout/global/global_data.dart';
import '../../apis/api_service.dart';
import '../../apis/poll_questions_service.dart';
import '../../apis/send_feedback_service.dart';
import '../../model/poll_model.dart';

class ReviewScreen extends StatefulWidget {
  final User user;

  const ReviewScreen({super.key, required this.user});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Future<List<PollQuestion>> pollQuestionsFuture;
  final FeedbackService feedbackService = FeedbackService();

  final SendFeedbackService sendFeedbackService = SendFeedbackService();

  // Track selected options for each question
  Map<String, String> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    // Fetch poll questions when the screen loads
    pollQuestionsFuture =
        PollService().fetchPollQuestions(GlobalData().userId.toString());
  }

  // Function to group poll questions by category
  Map<String, List<PollQuestion>> _groupQuestionsByCategory(
      List<PollQuestion> pollQuestions) {
    Map<String, List<PollQuestion>> groupedQuestions = {};
    for (var question in pollQuestions) {
      if (groupedQuestions.containsKey(question.associatedCategory)) {
        groupedQuestions[question.associatedCategory]!.add(question);
      } else {
        groupedQuestions[question.associatedCategory] = [question];
      }
    }
    return groupedQuestions;
  }

  // Function to handle the API call for sending feedback
  void _sendFeedback(String questionId, String selectedOption) async {
    try {
      final response = await feedbackService.sendFeedback(
        userId: GlobalData().userId.toString(),
        questionId: questionId,
        schoolId: widget.user.id,
        feedbackText: selectedOption,
      );

      // Handle success
      _sendFeedbackResponse(questionId);
      print('Feedback submitted: ${response['message']}');
    } catch (e) {
      // Handle failure
      print('Error submitting feedback: $e');
    }
  }

  void _sendFeedbackResponse(String questionId) async {
    try {
      final response = await sendFeedbackService.sendFeedbackResponseService(
        userId: GlobalData().userId.toString(),
        questionId: questionId,
        schoolId: widget.user.id,
      );

      // Handle success
      print('Feedback submitted: ${response?['message']}');
    } catch (e) {
      // Handle failure
      print('Error submitting feedback: $e');
    }
  }

  Widget _createChart() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
            border: Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(width: 1),
              bottom: BorderSide(width: 1),
            ),
          ),
          groupsSpace: 4,
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: 5, fromY: 0, width: 15, color: Colors.green)
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: 5, fromY: 0, width: 15, color: Colors.green)
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: 5, fromY: 0, width: 15, color: Colors.green)
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: 5, fromY: 0, width: 15, color: Colors.green)
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('School Review')),
      body: FutureBuilder<List<PollQuestion>>(
        future: pollQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No poll questions available'));
          } else {
            List<PollQuestion> pollQuestions = snapshot.data!;
            var groupedQuestions = _groupQuestionsByCategory(pollQuestions);

            return ListView(
              children: groupedQuestions.entries.map((entry) {
                String category = entry.key;
                List<PollQuestion> questionsInCategory = entry.value;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: questionsInCategory.map((poll) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        poll.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10.0,
                                        children: poll.options.map((option) {
                                          return OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                // Update the selected option for the current question
                                                selectedOptions[poll.id] =
                                                    option;

                                                // Send the selected option to the API
                                                _sendFeedback(poll.id, option);
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor:
                                                  selectedOptions[poll.id] ==
                                                          option
                                                      ? Colors.blueAccent
                                                          .withOpacity(0.2)
                                                      : Colors.white,
                                            ),
                                            child: Text(option),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Column(
                                children: [_createChart()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
