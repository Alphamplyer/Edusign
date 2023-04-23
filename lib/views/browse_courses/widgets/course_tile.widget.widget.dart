
import 'package:edusign_v3/config/constants.dart';
import 'package:edusign_v3/config/edusign_colors.dart';
import 'package:edusign_v3/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CourseTile extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final DateFormat _dateFormat = DateFormat.Hm();
  
  CourseTile({
    super.key,
    required this.course,
    this.onTap,
  });

  Color _getPresenceColor(BuildContext context) {
    if (course.presence) {
      return EdusignColors.successColorForeground;
    } else if (course.absence) {
      return EdusignColors.errorColorForeground;
    } else {
      return Theme.of(context).colorScheme.outline;
    }
  }

  String _getPresenceMessage() {
    if (course.presence) {
      return "Present";
    } else if (course.absence) {
      return "Absent";
    } else {
      return "Not Scanned";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _getPresenceColor(context),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Constants.kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "${_dateFormat.format(course.start)} - ${_dateFormat.format(course.end)}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                _getPresenceMessage(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: _getPresenceColor(context),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}