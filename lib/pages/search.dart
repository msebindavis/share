import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Text('Search');
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return linearProgress();
  }
}
