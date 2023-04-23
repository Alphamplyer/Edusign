
import 'package:flutter/material.dart';

import 'user_model.dart';

class UserCourseDetails extends ChangeNotifier {
  bool presence;
  bool absence;

  UserCourseDetails({
    required this.presence,
    required this.absence,
  });

  void setPresence(bool presence) {
    this.presence = presence;
  }

  void setAbsence(bool absence) {
    this.absence = absence;
  }
}

class MergedCourse {
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  final String professor;
  final Map<String, UserCourseDetails> userCourseDetails;

  MergedCourse({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.professor,
    required this.userCourseDetails,
  });

  void setUserPresence(String username, bool presence) {
    userCourseDetails[username]!.setPresence(presence);
  }

  void setUserAbsence(User user, bool absence) {
    userCourseDetails[user.username]!.setAbsence(absence);
  }
}