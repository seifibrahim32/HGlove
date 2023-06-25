import 'package:flutter/material.dart';

List<BottomNavigationBarItem> bottomNavigatorBarItems({num? currentIndex}) => [
      BottomNavigationBarItem(
          icon: Container(
              decoration: BoxDecoration(
                  color: currentIndex == 0 ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.health_and_safety,
                  color: currentIndex == 0 ? Colors.white : Colors.grey,
                ),
              )),
          backgroundColor: Colors.green,
          label: 'Diagnose'),
      BottomNavigationBarItem(
          icon: Container(
              decoration: BoxDecoration(
                  color: currentIndex == 1 ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.dashboard,
                    color: currentIndex == 1 ? Colors.white : Colors.grey),
              )),
          backgroundColor: Colors.green,
          label: 'Overview'),
      BottomNavigationBarItem(
          icon: Container(
              decoration: BoxDecoration(
                  color: currentIndex == 2 ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.access_time_filled,
                    color: currentIndex == 2 ? Colors.white : Colors.grey),
              )),
          label: 'Appointments'),
      BottomNavigationBarItem(
          icon: Container(
              decoration: BoxDecoration(
                  color: currentIndex == 3 ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.settings,
                    color: currentIndex == 3 ? Colors.white : Colors.grey),
              )),
          backgroundColor: Colors.green,
          label: 'Settings')
    ];
