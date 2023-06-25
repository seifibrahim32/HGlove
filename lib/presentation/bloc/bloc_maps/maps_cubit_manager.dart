import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controllers/network/maps_api.dart';
import '../../../domain/models/nearest_doctors_places_model.dart';
import 'maps_states.dart';

class MapsCubit extends Cubit<MapsStates> {
  static Position? position;

  static final Set<Marker> markers = {};

  static late CameraPosition cameraPosition;

  MapsCubit() : super(LocationUnInitialized());

  Future<MapsModel?> fetchLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (markers.isNotEmpty) {
      markers.clear();
    }
    markers.add(Marker(
      markerId: const MarkerId('You'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(position!.latitude, position!.longitude),
    ));
    try {
      cameraPosition = CameraPosition(
        target: LatLng(position!.latitude, position!.longitude),
        zoom: 14.4746,
      );
    } catch(e){
      print(e);
    }
    log('lat: ${position!.latitude} , lang: ${position!.longitude}');
    emit(LocationInitialized());
    return null;
  }

  fetchNearPlaces() async {
    await MapsAPI.fetchNearPlaces(position!.latitude, position!.longitude)
        .then((map) => map?.results?.forEach((result) {
              createNewMarkers(result.name!, result.geometry?.location?.lat,
                  result.geometry?.location?.lng);
            }));
    emit(MarkersCreated());
  }

  static createNewMarkers(
      String clinicName, double? latitude, double? longitude) {
    markers.add(Marker(
        markerId: MarkerId(clinicName),
        infoWindow: InfoWindow(title: clinicName),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(latitude!, longitude!)));
  }
}
