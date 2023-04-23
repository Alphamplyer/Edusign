

import 'package:edusign_v3/config/constants.dart';
import 'package:flutter/material.dart';



class EdusignScaffold extends StatelessWidget {
  final Widget body;
  final Drawer? drawer;
  final String title;

  const EdusignScaffold({
    super.key,
    required this.body,
    this.drawer,
    required this.title,
  });

  List<Widget> _buildPopButton(BuildContext context) {
    return [
      Container(
        height: Constants.kEdusignAppBarHeight,
        width: Constants.kEdusignAppBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(Constants.kDefaultBorderRadius)),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      const SizedBox(width: 16),
    ];
  }

  Widget _buildTitle(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: Constants.kDefaultPadding),
        height: Constants.kEdusignAppBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(Constants.kDefaultBorderRadius)),
        ),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer, 
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      const SizedBox(width: 16),
      Container(
        height: Constants.kEdusignAppBarHeight,
        width: Constants.kEdusignAppBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(Constants.kDefaultBorderRadius)),
        ),
        child: IconButton(
          icon: Icon(Icons.menu_rounded),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          onPressed: () => drawer != null ? Scaffold.of(context).openDrawer() : null,
        ),
      ),
    ];
  }

  Widget _buildAppBar(BuildContext context) {
    List<Widget> rowChildren = [];

    if (Navigator.canPop(context)) {
      rowChildren.addAll(_buildPopButton(context));
    }

    rowChildren.add(_buildTitle(context));

    if (drawer != null) {
      rowChildren.addAll(_buildActions(context));
    }

    return Padding(
      padding: const EdgeInsets.all(Constants.kDefaultPadding),
      child: Row(
        children: rowChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
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