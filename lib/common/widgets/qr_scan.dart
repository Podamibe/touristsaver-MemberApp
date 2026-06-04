import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:touristsaver/common/widgets/scanner_error_widget.dart';
import '../services/image_service.dart';
import 'custom_app_bar.dart';
import 'package:touristsaver/generated/l10n.dart';
import 'custom_snackbar.dart';

class QRScannerScreen extends StatefulWidget {
  static const String routeName = '/qr_screen';
  const QRScannerScreen({super.key, required this.title});
  final String title;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ImageService _imageService = ImageService();
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: true,
    autoStart: true,
  );

  late AnimationController _animationController;
  late Animation<double> _animation;

  String _scanResult = '';
  bool isLoading = false;
  bool _debugQrShortcutUsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        unawaited(cameraController.stop());
        break;

      case AppLifecycleState.resumed:
        unawaited(cameraController.start());
        break;

      default:
        break;
    }
  }

  // Future<void> _onDetect(BarcodeCapture capture) async {
  //   try {
  //     final barcodes = capture.barcodes;
  //     if (barcodes.isNotEmpty) {
  //       _scanResult = barcodes.first.rawValue ?? '';
  //       // log("Detected Barcode: $_scanResult");
  //       if (_scanResult.isNotEmpty) {

  //         context.pop(_scanResult);
  //         await cameraController.dispose();
  //       }
  //     }
  //   } catch (e) {
  //     _resetScanState();
  //     // log("Error in _onDetect: ${e.toString()}");
  //     GlobalSnackBar.showError(context, e.toString());
  //   }
  // }
  Future<void> _onDetect(BarcodeCapture capture) async {
    try {
      final barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final result = barcodes.first.rawValue ?? '';
        if (result.isNotEmpty && _scanResult != result) {
          _scanResult = result;
          context.pop(_scanResult);
        }
      }
    } catch (e) {
      _resetScanState();
      GlobalSnackBar.showError(context, e.toString());
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() => isLoading = true);
    try {
      final image = await _imageService.pickImage(ImageSource.gallery);
      if (image != null) {
        final croppedImage = await _imageService.cropImage(image.path);
        if (croppedImage != null) {
          final result = await cameraController.analyzeImage(croppedImage.path);
          if (result != null && result.barcodes.isNotEmpty) {
            _scanResult = result.barcodes.first.rawValue ?? '';
            // log("Gallery Barcode: $_scanResult");
            if (_scanResult.isNotEmpty) {
              context.pop(_scanResult);
            }
          } else {
            GlobalSnackBar.valid(context, S.of(context).invalidQrCode);
          }
        }
      }
    } catch (e) {
      _resetScanState();
      // log("Error in _scanFromGallery: ${e.toString()}");
      GlobalSnackBar.showError(context, e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetScanState() {
    setState(() {
      _scanResult = '';
      isLoading = false;
    });
  }

  KeyEventResult _handleDebugQrShortcut(FocusNode node, KeyEvent event) {
    if (!kDebugMode || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (_debugQrShortcutUsed || event.logicalKey != LogicalKeyboardKey.keyQ) {
      return KeyEventResult.ignored;
    }

    // Debug-only emulator shortcut for testing QR redemption without camera scan.
    _debugQrShortcutUsed = true;
    context.pop('6660000000058');
    return KeyEventResult.handled;
  }

  @override
  void dispose() async {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(2, -100)),
      width: 225,
      height: 225,
    );

    return Focus(
      autofocus: true,
      onKeyEvent: _handleDebugQrShortcut,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: widget.title,
            icon: Icons.arrow_back_ios,
            onPressed: () => context.pop(_scanResult),
            icon2: Icons.flash_on,
            onPressed2: () => cameraController.toggleTorch(),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else
              MobileScanner(
                key: UniqueKey(),
                fit: BoxFit.cover,
                controller: cameraController,
                scanWindow: scanWindow,
                onDetect: _onDetect,
                errorBuilder: (context, error, child) =>
                    ScannerErrorWidget(error: error),
              ),
            if (!isLoading)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => CustomPaint(
                  painter: ScannerOverlay(
                    scanWindow: scanWindow,
                    animationValue: _animation.value,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.image, size: 35, color: Colors.white),
                  onPressed: _scanFromGallery,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
    required this.animationValue,
    this.loaderLinePadding = 10.0,
  });

  final Rect scanWindow;
  final double borderRadius;
  final double animationValue;
  final double loaderLinePadding;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);

    final loaderLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final loaderLineY = scanWindow.top + (scanWindow.height * animationValue);
    final loaderLineStartX = scanWindow.left + loaderLinePadding;
    final loaderLineEndX = scanWindow.right - loaderLinePadding;

    canvas.drawLine(
      Offset(loaderLineStartX, loaderLineY),
      Offset(loaderLineEndX, loaderLineY),
      loaderLinePaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius ||
        animationValue != oldDelegate.animationValue ||
        loaderLinePadding != oldDelegate.loaderLinePadding;
  }
}

///
///// // ignore_for_file: use_build_context_synchronously, deprecated_member_use
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:touristsaver/common/widgets/scanner_error_widget.dart';
// import '../services/image_service.dart';
// import 'custom_app_bar.dart';
// import 'package:touristsaver/generated/l10n.dart';
// import 'custom_snackbar.dart';
// // import '../../../constants/fixed_decimal.dart';
// // import 'package:intl/intl.dart';
// // import '../../../common/app_variables.dart';
// // import '../../../models/error_res.dart';
// // import '../../../models/request/confirm_piiink_req.dart';
// // import '../../../models/response/confirm_piiink_res.dart';
// // import '../services/dio_payment.dart';

// class QRScannerScreen extends StatefulWidget {
//   static const String routeName = '/qr_screen';
//   const QRScannerScreen({super.key});
//   // final String? amount;
//   // final String clickedButton;

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen>
//     with SingleTickerProviderStateMixin {
//   final ImageService _imageService = ImageService();
//   final MobileScannerController cameraController = MobileScannerController(
//       detectionSpeed: DetectionSpeed.noDuplicates,
//       returnImage: true,
//       autoStart: true);
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   // For Loader
//   String _scanResult = '';
//   bool isLoading = false;

// // Function to handle barcode detection from the camera
//   Future<void> _onDetect(BarcodeCapture capture) async {
//     try {
//       final List<Barcode> barcodes = capture.barcodes;
//       if (barcodes.isNotEmpty) {
//         _scanResult = barcodes.first.rawValue ?? '';
//         log("Detected Barcode: $_scanResult");
//         if (_scanResult.isNotEmpty) {
//           context.pop(_scanResult);
//         }
//       }
//     } catch (e) {
//       _resetScanState();
//       log("Error in _onDetect: ${e.toString()}");
//       return GlobalSnackBar.showError(context, e.toString());
//     }
//   }

// // Function to scan a QR code from the gallery
//   Future<void> _scanFromGallery() async {
//     isLoading = true;
//     try {
//       final image = await _imageService.pickImage(ImageSource.gallery);
//       if (image != null) {
//         final croppedImage = await _imageService.cropImage(image.path);
//         if (croppedImage != null) {
//           final BarcodeCapture? result =
//               await cameraController.analyzeImage(croppedImage.path);
//           if (result != null) {
//             final List<Barcode> barcodes = result.barcodes;
//             if (barcodes.isNotEmpty) {
//               _scanResult = barcodes.first.rawValue ?? '';
//               log("Gallery Barcode: $_scanResult");
//               if (_scanResult.isNotEmpty) {
//                 context.pop(_scanResult);
//               }
//             }
//           } else {
//             return GlobalSnackBar.valid(context, S.of(context).invalidQrCode);
//           }
//         }
//       }
//     } catch (e) {
//       _resetScanState();
//       log("Error in _scanFromGallery: ${e.toString()}");
//       GlobalSnackBar.showError(context, e.toString());
//     }
//   }

// // Helper to reset scan state
//   void _resetScanState() {
//     _scanResult = '';
//     isLoading = false;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat();
//     _animation = Tween<double>(begin: 1, end: 0).animate(_animationController);
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scanWindow = Rect.fromCenter(
//       center: MediaQuery.sizeOf(context).center(const Offset(2, -100)),
//       width: 225,
//       height: 225,
//     );

//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.1),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: CustomAppBar(
//           text: S.of(context).pay,
//           icon: Icons.arrow_back_ios,
//           onPressed: () {
//             context.pop(_scanResult);
//           },
//           icon2: Icons.flash_on,
//           onPressed2: () => cameraController.toggleTorch(),
//         ),
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           isLoading
//               ? Center(child: CircularProgressIndicator(strokeWidth: 2))
//               : MobileScanner(
//                   fit: BoxFit.cover,
//                   controller: cameraController,
//                   scanWindow: scanWindow,
//                   onDetect: _onDetect,
//                   errorBuilder: (context, error, child) {
//                     return ScannerErrorWidget(
//                       error: error,
//                     );
//                   },
//                 ),
//           isLoading
//               ? Center(child: CircularProgressIndicator(strokeWidth: 2))
//               : AnimatedBuilder(
//                   animation: _animation,
//                   builder: (context, child) {
//                     return CustomPaint(
//                       painter: ScannerOverlay(
//                         scanWindow: scanWindow,
//                         animationValue: _animation.value,
//                       ),
//                     );
//                   },
//                 ),
//           Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: InkWell(
//                 onTap: () {
//                   _scanFromGallery();
//                 },
//                 child: const Icon(Icons.image, size: 35, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ScannerOverlay extends CustomPainter {
//   const ScannerOverlay({
//     required this.scanWindow,
//     this.borderRadius = 12.0,
//     required this.animationValue, // Add animation value for the loader line
//     this.loaderLinePadding = 10.0, // Padding to make the loader line shorter
//   });

//   final Rect scanWindow;
//   final double borderRadius;
//   final double
//       animationValue; // Value between 0 and 1 for the loader line position
//   final double loaderLinePadding; // Padding for the loader line

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw the background with a cutout
//     final backgroundPath = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

//     final cutoutPath = Path()
//       ..addRRect(
//         RRect.fromRectAndCorners(
//           scanWindow,
//           topLeft: Radius.circular(borderRadius),
//           topRight: Radius.circular(borderRadius),
//           bottomLeft: Radius.circular(borderRadius),
//           bottomRight: Radius.circular(borderRadius),
//         ),
//       );

//     final backgroundPaint = Paint()
//       ..color = Colors.black.withOpacity(0.5)
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOver;

//     final backgroundWithCutout = Path.combine(
//       PathOperation.difference,
//       backgroundPath,
//       cutoutPath,
//     );

//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     final borderRect = RRect.fromRectAndCorners(
//       scanWindow,
//       topLeft: Radius.circular(borderRadius),
//       topRight: Radius.circular(borderRadius),
//       bottomLeft: Radius.circular(borderRadius),
//       bottomRight: Radius.circular(borderRadius),
//     );

//     // Draw the background with the cutout
//     canvas.drawPath(backgroundWithCutout, backgroundPaint);
//     canvas.drawRRect(borderRect, borderPaint);

//     // Draw the loader line
//     final loaderLinePaint = Paint()
//       ..color = Colors.white // Change color as needed
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     // Calculate the position of the loader line based on the animation value
//     final loaderLineY = scanWindow.top + (scanWindow.height * animationValue);

//     // Adjust the start and end points of the loader line to make it shorter
//     final loaderLineStartX = scanWindow.left + loaderLinePadding;
//     final loaderLineEndX = scanWindow.right - loaderLinePadding;

//     // Draw the horizontal loader line
//     canvas.drawLine(
//       Offset(loaderLineStartX, loaderLineY),
//       Offset(loaderLineEndX, loaderLineY),
//       loaderLinePaint,
//     );
//   }

//   @override
//   bool shouldRepaint(ScannerOverlay oldDelegate) {
//     return scanWindow != oldDelegate.scanWindow ||
//         borderRadius != oldDelegate.borderRadius ||
//         animationValue != oldDelegate.animationValue ||
//         loaderLinePadding != oldDelegate.loaderLinePadding;
//   }
// }
