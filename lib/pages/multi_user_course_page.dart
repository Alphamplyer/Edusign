import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/pages/login_users_page.dart';
import 'package:edusign_v3/pages/multi_user_course_scanner_page.dart';
import 'package:edusign_v3/services/course_service.dart';
import 'package:edusign_v3/widgets/acrylic_appbar.dart';
import 'package:edusign_v3/widgets/course_tile_widget.dart';
import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../services/edusign_service.dart';

class MultiUserCoursePage extends StatefulWidget {
  final List<User> users;
  
  const MultiUserCoursePage({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  State<MultiUserCoursePage> createState() => _MultiUserCoursePageState();
}

class _MultiUserCoursePageState extends State<MultiUserCoursePage> {
  Future<List<Course>>? _coursesFuture;
  List<Course> _courses = [];
  List<Course> _todayCourses = [];
  final ValueNotifier<bool> _showFutureCourses = ValueNotifier(false);

  @override
  void initState() {
    _coursesFuture = CourseService
      .getUsersCoursesInCommon(widget.users)
      .then((value) {
        _courses = value;

        var now = DateTime.now();
        var startDay = DateTime(now.year, now.month, now.day);
        var endDay = DateTime(now.year, now.month, now.day)
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));

        _todayCourses = _courses
          .where((course) => startDay.isBefore(course.start) && endDay.isAfter(course.end))
          .toList();

        return value;
      });

    super.initState();
  }

  void _onTileTap(Course course) {
    if (course.presence || course.absence) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiUserCourseScannerPage(
          course: course,
          users: widget.users,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                SizedBox(width: 8),
                const Text('Show Future Courses'),
                Spacer(),
                Switch(
                  value: _showFutureCourses.value,
                  onChanged: (value) {
                    setState(() {
                      _showFutureCourses.value = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Center(child: Text('Logout')),
                onTap: () {
                  EdusignService.user = null;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginUsersPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF4CA1AF),
          ],
        ),
      ),
      child: Scaffold(
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF4CA1AF),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcrylicAppbar(
                  title: Text(
                    'Courses',
                    style: Theme.of(context).textTheme.titleLarge!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Course>>(
                    future: _coursesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ValueListenableBuilder(
                            valueListenable: _showFutureCourses,
                            builder: (context, value, child) {
                              List<Course> courses =
                                  value ? _courses : _todayCourses;
                              return ListView.builder(
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  return CourseTile(
                                    course: courses[index],
                                    onTap: _onTileTap,
                                  );
                                },
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Container(
                          color: Colors.red,
                          child: Center(
                            child: Text('${snapshot.error}'),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
