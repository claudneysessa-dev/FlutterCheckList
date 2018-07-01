import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/CheckList.dart';
import 'package:flutter_app/model/StepCard.dart';
import 'package:flutter_app/model/StepClass.dart';

class EditCheckList extends StatefulWidget {

  const EditCheckList({Key key, this.checkList}) : super(key: key);
  final CheckList checkList;
  @override
  _AppBarBottomSampleState createState() => _AppBarBottomSampleState(checkList);
}

class _AppBarBottomSampleState extends State<EditCheckList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  CheckList checkList;
  StepClass currentStep;

  _AppBarBottomSampleState(CheckList checkList) {
    this.checkList = checkList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: checkList.steps.length);
    currentStep = checkList.steps[0];
    _tabController.addListener(_stepSelected);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextPage(int delta) {
    final int newIndex = _tabController.index + delta;
    if (newIndex < 0 || newIndex >= _tabController.length) return;
    _tabController.animateTo(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: new Text(currentStep.name),
          leading: IconButton(
            tooltip: 'Previous choice',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _nextPage(-1);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: 'Next choice',
              onPressed: () {
                _nextPage(1);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: Container(
                height: 48.0,
                alignment: Alignment.center,
                child: TabPageSelector(controller: _tabController),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: checkList.steps.map((StepClass step) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: StepCard(step: step),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _stepSelected() {
    setState(() {
      currentStep = checkList.steps[_tabController.index];
    });
  }
}
