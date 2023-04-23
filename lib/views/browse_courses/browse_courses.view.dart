
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/models/course_model.dart';
import 'package:edusign_v3/views/browse_courses/browse_courses.view_model.dart';
import 'package:edusign_v3/views/browse_courses/widgets/course_tile.widget.widget.dart';
import 'package:edusign_v3/views/select_users/select_users.view.dart';
import 'package:edusign_v3/widgets/edusign_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BrowseCoursesView extends StatefulWidget {
  const BrowseCoursesView({super.key});

  @override
  State<BrowseCoursesView> createState() => _BrowseCoursesViewState();
}

class _BrowseCoursesViewState extends State<BrowseCoursesView> {
  late BrowseCoursesViewModel _viewModel;
  final DateFormat dateFormat = DateFormat.yMMMMd();

  @override
  void initState() {
    _viewModel = BrowseCoursesViewModel();
    super.initState();
    _viewModel.loadState();
  }

  Future<void> _navigateToCourseScanView(String courseId) async {
    bool? isModified = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectUsersView(courseId: courseId),
      ),
    );

    if (isModified == true)
      await _viewModel.refreshState();
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text('Edusign'),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: _viewModel.displayOnlyNextCourses, 
                  onChanged: (value) => _viewModel.toggleDisplayOnlyNextCourses()
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool isDifferentDay(DateTime date1, DateTime date2) {
    return date1.day != date2.day || date1.month != date2.month || date1.year != date2.year;
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.kDefaultPadding),
      child: Text(
        isToday(date) ? "Today" : dateFormat.format(date),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  ListView _buildAddCoursesListView() {
    return _buildCoursesListView(_viewModel.courses);
  }

  ListView _buildOnlyNextCoursesListView() {
    return _buildCoursesListView(_viewModel.nextCourses);
  }

  ListView _buildCoursesListView(List<Course> courses) {
    DateTime previousDate = DateTime.now().subtract(Duration(days: 365));
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        Course course = courses[index];
        bool displayDate = isDifferentDay(course.start, previousDate);
        previousDate = course.start;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (displayDate)
              _buildDateHeader(course.start),
            CourseTile(
              key: ValueKey(course.id),  
              course: course,
              onTap: () => _navigateToCourseScanView(course.id)
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return EdusignScaffold(
      title: 'Browse Courses',
      drawer: _buildDrawer(),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Constants.kDefaultPadding),
              child: _viewModel.displayOnlyNextCourses 
                ? _buildOnlyNextCoursesListView() 
                : _buildAddCoursesListView(),
            );
          }
        },
      ),
    );
  }
}