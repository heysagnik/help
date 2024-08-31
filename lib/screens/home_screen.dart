import 'dart:async';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:help/screens/rescue_screen.dart';
import 'package:help/provider/location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:help/widgets/slidetoact.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  bool isFinished = false;
  bool _animate = true;
  final _picker = ImagePicker();
  XFile? _imageFile;
  String? _currentAddress;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (await _locationService.handleLocationPermission()) {
      _getCurrentPosition();
      _listenToLocationChanges();
    }
  }

  void _navigateToScreen(Widget screen) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 200),
        child: screen,
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    Position? position = await _locationService.getCurrentPosition();
    if (position != null) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(position);
    }
  }

  void _listenToLocationChanges() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng(position);
      });
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    String? address = await _locationService.getAddressFromLatLng(position);
    if (address != null) {
      setState(() {
        _currentAddress = address;
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  void _showConfirmationBottomSheet() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_imageFile != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 10.0),
            if (_currentPosition != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  Text(
                    "${_currentPosition!.latitude.toStringAsFixed(3)},${_currentPosition!.longitude.toStringAsFixed(3)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_outlined),
                Text(
                  ap.userModel.phoneNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: SlideAction(
                textColor: Colors.red,
                text: 'Send',
                borderRadius: 50,
                elevation: 0,
                innerColor: Colors.red[600],
                outerColor: Colors.red[100],
                onSubmit: () {
                  _navigateToScreen(const RescueScreen());
                  return null;
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              onPressed: _getCurrentPosition,
              icon: const Icon(Icons.my_location_outlined),
            ),
            Text(' ${_currentAddress ?? ""}')
          ],
        ),
        leadingWidth: 200,
        actions: [
          IconButton(
            onPressed: () => _navigateToScreen(const ProfileScreen()),
            icon: CircleAvatar(
              backgroundColor: Colors.redAccent.shade100,
              backgroundImage: NetworkImage(ap.userModel.profilePic),
              radius: 20,
              child: ap.userModel.profilePic.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey.shade50,
        indicatorColor: Colors.red.shade400,
        animationDuration: const Duration(milliseconds: 100),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.emergency), label: 'Emergency'),
          NavigationDestination(icon: Icon(Icons.support), label: 'Rescue'),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            _navigateToScreen(const RescueScreen());
          }
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                AvatarGlow(
                  animate: _animate,
                  glowColor: Colors.redAccent,
                  glowRadiusFactor: 0.5,
                  child: Material(
                    elevation: 8.0,
                    shape: const CircleBorder(),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _captureImage();
                          await _getCurrentPosition();
                          if (_imageFile != null && _currentPosition != null) {
                            _showConfirmationBottomSheet();
                          }
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade500),
                          shape: MaterialStateProperty.all<CircleBorder>(
                              const CircleBorder()),
                        ),
                        child: const Icon(Icons.sos, size: 100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
