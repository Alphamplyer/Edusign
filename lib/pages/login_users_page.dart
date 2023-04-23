import 'dart:io';

import 'package:edusign_v3/config/storage_keys.dart';
import 'package:edusign_v3/models/user_credential.dart';
import 'package:edusign_v3/models/user_model.dart';
import 'package:edusign_v3/pages/add_user_page.dart';
import 'package:edusign_v3/pages/multi_user_course_page.dart';
import 'package:edusign_v3/services/edusign_service.dart';
import 'package:edusign_v3/services/storage_service.dart';
import 'package:edusign_v3/services/user_credentials_service.dart';
import 'package:edusign_v3/widgets/acrylic_appbar.dart';
import 'package:edusign_v3/widgets/login_multi_user_form.dart';
import 'package:flutter/material.dart';

class LoginUsersPage extends StatefulWidget {
  const LoginUsersPage({super.key});

  @override
  State<LoginUsersPage> createState() => _LoginUsersPageState();
}

class _LoginUsersPageState extends State<LoginUsersPage> {
  late Future<void> _stateLoading;
  List<UserCredential> usersCrendentials = [];
  List<String> previouslySelectedUsernames = [];
  bool rememberPassword = false;
  
  @override
  void initState() {
    _stateLoading = _loadState();
    super.initState();
  }

  Future<bool> _loadState() async {
    usersCrendentials = await UserCredentialsService.loadAllUsersCredentials();
    String? storedValueOfPreviouslySelectedUsernames = (await StorageService.read(key: StorageKeys.PREVIOUSLY_SELECTED_USERNAMES));
    if (storedValueOfPreviouslySelectedUsernames != null) {
      previouslySelectedUsernames = storedValueOfPreviouslySelectedUsernames.split(',');
    }
    return true;
  }

  void onLogin(List<String> userNames) async {
    if (usersCrendentials.isEmpty) return;

    List<UserCredential> usersCredentialsToLogin = usersCrendentials
      .where((element) => userNames
      .contains(element.username))
      .toList();

    List<User> loggedUsers = await loginUsers(usersCredentialsToLogin);

    if (!mounted) return;

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => MultiUserCoursePage(users: loggedUsers))
    );
  }

  Future<List<User>> loginUsers(List<UserCredential> usersCredentialsToLogin) async {
    List<User> loggedUsers = [];

    try {
      for (var userCredentials in usersCredentialsToLogin) {
        User loggedUser = await EdusignService.login(userCredentials.username, userCredentials.password);
        loggedUsers.add(loggedUser);
      }
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to login'),
        ),
      );
    }

    return loggedUsers;
  }

  void onAddUser() async {
    bool? isUserAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddUserPage(),
      ),
    );

    if (!mounted) return;

    if (isUserAdded != null) {
      setState(() {
        _stateLoading = _loadState();
      });
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Card(
              child: ListTile(
                title: const Center(child: Text('Add an user')),
                onTap: onAddUser,
              ),
            ),
            Card(
              child: ListTile(
                title: const Center(child: Text('Clear saved users')),
                onTap: () {
                  UserCredentialsService.deleteUsersCredentials();
                  previouslySelectedUsernames.clear();
                  setState(() {
                    _stateLoading = _loadState();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserAdded(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No users added yet\nAdd an user to continue',
            style: Theme.of(context).textTheme.titleMedium!,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: onAddUser,
            child: const Text('Add an user'),
          ),
        ],
      )
    );
  }

  Widget _buildHasUserAdded(BuildContext context) {
    return LoginMultiUserForm(
      userNames: usersCrendentials
        .map((e) => e.username)
        .toList(), 
      previouslySelectedUsernames: previouslySelectedUsernames,
      onLogin: onLogin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: FutureBuilder(
                  future: _stateLoading,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return usersCrendentials.isEmpty
                        ? _buildNoUserAdded(context)
                        : _buildHasUserAdded(context);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
