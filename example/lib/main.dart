// Copyright 2023 Freedelity. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';

void main() async {
  runZonedGuarded(() async {
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();

    runApp(const MyApp());
  }, (e, stacktrace) async {
    debugPrint('$e, $stacktrace');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

enum CameraActions {
  flipCamera,
  toggleFlashlight,
  stopScanner,
  startScanner,
  setOverlay
}

class _MyAppState extends State<MyApp> {
  bool withOverlay = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: const Text('Scanner plugin example app'),
                actions: [
                  PopupMenuButton<CameraActions>(
                    onSelected: (CameraActions result) {
                      switch (result) {
                        case CameraActions.flipCamera:
                          BarcodeScanner.flipCamera();
                          break;
                        case CameraActions.toggleFlashlight:
                          BarcodeScanner.toggleFlashlight();
                          break;
                        case CameraActions.stopScanner:
                          BarcodeScanner.stopScanner();
                          break;
                        case CameraActions.startScanner:
                          BarcodeScanner.startScanner();
                          break;
                        case CameraActions.setOverlay:
                          setState(() => withOverlay = !withOverlay);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<CameraActions>>[
                      const PopupMenuItem<CameraActions>(
                        value: CameraActions.flipCamera,
                        child: Text('Flip camera'),
                      ),
                      const PopupMenuItem<CameraActions>(
                        value: CameraActions.toggleFlashlight,
                        child: Text('Toggle flashlight'),
                      ),
                      const PopupMenuItem<CameraActions>(
                        value: CameraActions.stopScanner,
                        child: Text('Stop scanner'),
                      ),
                      const PopupMenuItem<CameraActions>(
                        value: CameraActions.startScanner,
                        child: Text('Start scanner'),
                      ),
                      PopupMenuItem<CameraActions>(
                        value: CameraActions.setOverlay,
                        child:
                            Text('${withOverlay ? 'Remove' : 'Add'} overlay'),
                      ),
                    ],
                  ),
                ]),
            body: Builder(builder: (builderContext) {

              Widget child = BarcodeScannerWidget(
                onBarcodeDetected: (barcode) async {
                  await showDialog(
                      context: builderContext,
                      builder: (dialogContext) {
                        return Align(
                            alignment: Alignment.center,
                            child: Card(
                                margin: const EdgeInsets.all(24),
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('barcode : ${barcode.value}'),
                                          Text(
                                              'format : ${barcode.format.name}'),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Close dialog'))
                                        ]))));
                      });
                },
                onError: (dynamic error) {
                  debugPrint('$error');
                },
              );

              if (withOverlay) {
                return buildWithOverlay(builderContext, child);
              }

              return child;
            })));
  }

  buildWithOverlay(BuildContext builderContext, Widget scannerWidget) {
    return Stack(children: [
      Positioned.fill(child: scannerWidget),
      Align(
          alignment: Alignment.center,
          child: Divider(color: Colors.red[400], thickness: 0.8)),
      Center(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 64),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(15)))),
      Positioned(
          top: 16,
          right: 16,
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.purple),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(8))),
              onPressed: () {
                ScaffoldMessenger.of(builderContext).showSnackBar(
                    const SnackBar(content: Text('Icon button pressed')));
              },
              child: const Icon(Icons.refresh, size: 32)
              )),
    ]);
  }
}
