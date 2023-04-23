
import 'package:edusign_v3/config/constants.dart';
import 'package:flutter/material.dart';



class EdusignScaffold extends StatelessWidget {
  final Widget body;
  final String? title;

  const EdusignScaffold({
    super.key,
    required this.body,
    this.title,
  });

  Widget _buildAppBar(BuildContext context) {
    List<Widget> rowChildren = [];

    if (Navigator.canPop(context)) {
      rowChildren.addAll([
        Container(
          height: Constants.kEdusignAppBarHeight,
          width: Constants.kEdusignAppBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 16),
      ]);
    }

    rowChildren.add(
      Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: Constants.kEdusignAppBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Flexible(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: rowChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: body,
            ),
          ],
        ) ,
      )
    );
  }
}