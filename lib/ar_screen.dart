// ar_model_screen.dart
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart' hide Colors;

class ARModelScreen extends StatefulWidget {
  final String modelName;
  final String modelPath;

  const ARModelScreen({
    Key? key,
    required this.modelName,
    required this.modelPath,
  }) : super(key: key);

  @override
  State<ARModelScreen> createState() => _ARModelScreenState();
}

class _ARModelScreenState extends State<ARModelScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  bool modelPlaced = false;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: false,
    );

    arObjectManager!.onInitialize();

    // THIS IS THE MISSING PART: Add model on tap
    arSessionManager!.onPlaneOrPointTap = onPlaneTapped;
  }

  Future<void> onPlaneTapped(List<ARHitTestResult> hitTestResults) async {
    if (modelPlaced || hitTestResults.isEmpty) return;

    final hit = hitTestResults.first;
    final position = hit.worldTransform.getTranslation();

    final node = ARNode(
      type: NodeType.webGLB,
      uri: widget.modelPath,
      scale: Vector3(0.4, 0.4, 0.4),
      position: position,
    );

    final added = await arObjectManager!.addNode(node);
    if (added == true) {
      setState(() => modelPlaced = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AR View: ${widget.modelName}"),
      //  backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          if (!modelPlaced)
      const Center(
              child: Text(
                "Point at floor/table → Tap to place",
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 18,
                  //backgroundColor: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}