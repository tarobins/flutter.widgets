// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const defaultItemCount = 500;
const scrollDuration = Duration(seconds: 1);

void main() {
  Future<void> setUpWidgetTest(
    WidgetTester tester, {
    Key? key,
    ItemScrollController? itemScrollController,
    ItemPositionsListener? itemPositionsListener,
    int startingTab = 0,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 2,
          initialIndex: startingTab,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "ATAB"),
                  Tab(text: "BTAB"),
                ],
              ),
              title: Text('Tabs Demo'),
            ),
            body: TabBarView(
              children: [
                Text("AAA"),
                ScrollablePositionedList.builder(
                  key: key,
                  itemCount: defaultItemCount,
                  itemScrollController: itemScrollController,
                  itemBuilder: (context, index) {
                    assert(index >= 0 && index <= defaultItemCount - 1);
                    return SizedBox(
                      height: itemHeight,
                      child: Text('Item $index'),
                    );
                  },
                  itemPositionsListener: itemPositionsListener,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Switch tabs during animation', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();

    await setUpWidgetTest(tester,
        startingTab: 1, itemScrollController: itemScrollController);

    final tabController =
        DefaultTabController.of(tester.firstElement(find.byType(TabBar)));

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    tabController!.animateTo(0, duration: scrollDuration);

    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);
    await tester.pumpAndSettle();

    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('Item 0'), findsNothing);
  });
}
