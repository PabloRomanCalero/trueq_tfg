import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';

import '../../../../utils/constants/text_strings.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(40.4168, -3.7038);
  Marker? _marker;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return false;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));

        setState(() {
          _marker = Marker(
            markerId: MarkerId("searched_location"),
            position: newLatLng,
            infoWindow: InfoWindow(title: query),
          );
          _center = newLatLng;
        });
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(TextsTrueq.to.getText('error'), TextsTrueq.to.getText('locationNotFound'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(TextsTrueq.to.getText('permissionDenied'), TextsTrueq.to.getText('locationPermissionExplanation'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(TextsTrueq.to.getText('permissionDeniedForever'), TextsTrueq.to.getText('permissionSettingsMessage'), backgroundColor: Colors.red, colorText: ColorsTrueq.light);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final newLatLng = LatLng(position.latitude, position.longitude);
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final address = "${place.street}, ${place.locality}, ${place.country}";

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));
      if (mounted) {
        setState(() {
          _marker = Marker(
            markerId: MarkerId("current_location"),
            position: newLatLng,
            infoWindow: InfoWindow(title: TextsTrueq.to.getText('currentPosition')),
          );
          _center = newLatLng;
          _searchController.text = address;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextsTrueq.to.getText('location'),
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0.r),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsTrueq.light,
                borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                boxShadow: [
                  BoxShadow(
                    color: ColorsTrueq.dark.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Icon(Icons.search_rounded, color: ColorsTrueq.darkGrey, size: 24.sp,),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _searchLocation(),
                      decoration: InputDecoration(
                        hintText: TextsTrueq.to.getText('searchLocation'),
                        hintStyle: TextStyle(color: ColorsTrueq.darkGrey),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: ColorsTrueq.darkGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: ColorsTrueq.darkGrey, size: 24.sp,),
                      onPressed: _searchLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 12,
                  ),
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight.h + 60.h, right: SizesTrueq.defaultSpace.w, left: SizesTrueq.defaultSpace.w),
                  markers: _marker != null ? {_marker!} : {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng tappedPoint) async {
                    final placemarks = await placemarkFromCoordinates(tappedPoint.latitude, tappedPoint.longitude);
                    if (placemarks.isNotEmpty) {
                      final place = placemarks.first;
                      final address = "${place.street}, ${place.locality}, ${place.country}";
                      setState(() {
                        _marker = Marker(
                          markerId: MarkerId("custom_location"),
                          position: tappedPoint,
                          infoWindow: InfoWindow(title: address),
                        );
                        _center = tappedPoint;
                        _searchController.text = address;
                      });
                    }
                  },
                ),
                Positioned(
                  bottom: kBottomNavigationBarHeight.h,
                  left: SizesTrueq.defaultSpace.w,
                  right: SizesTrueq.defaultSpace.w,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_rounded, size: 22.sp, color: ColorsTrueq.light),
                    label: Text(
                      TextsTrueq.to.getText('confirmLocation'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ColorsTrueq.light,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsTrueq.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                      ),
                    ),
                    onPressed: () async {
                      if (_searchController.text.isNotEmpty) {
                        final response = await _searchLocation();
                        if (response) {
                          Get.back(result: _searchController.text);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
