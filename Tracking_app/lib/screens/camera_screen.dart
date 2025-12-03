import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../main.dart';
import '../services/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera available')),
        );
      }
      return;
    }

    _controller = await _cameraService.initializeCamera(cameras);

    if (_controller != null && mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Photo'),
        actions: [
          // Flash mode toggle
          IconButton(
            icon: Icon(_getFlashIcon()),
            onPressed: _toggleFlash,
            tooltip: 'Flash',
          ),
          // Gallery picker
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            tooltip: 'Gallery',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildCameraPreview(),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * size.aspectRatio);

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Switch camera
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
            color: Colors.white,
            iconSize: 32,
          ),
          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _captureImage,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isCapturing ? Colors.grey : Colors.transparent,
              ),
              child: _isCapturing
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
                  : const Icon(
                Icons.camera,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    final modes = [FlashMode.auto, FlashMode.off, FlashMode.always];
    final currentIndex = modes.indexOf(_flashMode);
    final nextIndex = (currentIndex + 1) % modes.length;

    _flashMode = modes[nextIndex];
    await _controller!.setFlashMode(_flashMode);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    final currentIndex = cameras.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % cameras.length;

    await _controller?.dispose();

    _controller = CameraController(
      cameras[nextIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    await _controller!.setFlashMode(_flashMode);

    if (mounted) setState(() {});
  }

  Future<void> _captureImage() async {
    if (_controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final imagePath = await _cameraService.captureImage(_controller!);

      if (imagePath != null && mounted) {
        Navigator.pop(context, imagePath);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image')),
        );
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final imagePath = await _cameraService.pickImageFromGallery();

    if (imagePath != null && mounted) {
      Navigator.pop(context, imagePath);
    }
  }
}