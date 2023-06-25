import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controllers/network/maps_api.dart';
import '../../bloc/bloc_maps/maps_cubit_manager.dart';
import '../../bloc/bloc_maps/maps_states.dart';

class MapsScreen extends StatefulWidget {
  final String? kind;

  const MapsScreen({super.key, required this.kind});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static late LatLng latLng;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.kind) {
      case 'doctors':
        return Scaffold(
          body: BlocProvider(
              create: (context) => MapsCubit(),
              child: BlocBuilder<MapsCubit, MapsStates>(
                builder: (context, state) {
                  if (state is LocationUnInitialized) {
                    context.read<MapsCubit>().fetchLocation();
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is LocationInitialized) {
                    context.read<MapsCubit>().fetchNearPlaces();
                  }
                  if (state is MarkersCreated) {
                    return GoogleMap(
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                      markers: MapsCubit.markers,
                      mapType: MapType.hybrid,
                      initialCameraPosition: MapsCubit.cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )),
        );
      case 'location':
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: const Text('Select location',
                style: TextStyle(fontFamily: 'SF',color:Colors.black)),
          ),
          body: Center(
            child: BlocProvider(
              create: (context) => MapsCubit(),
              child: BlocBuilder<MapsCubit, MapsStates>(
                builder: (context,state) {
                  if (state is LocationUnInitialized) {
                    context.read<MapsCubit>().fetchLocation();
                    return const Center(child: CircularProgressIndicator());
                  }
                  Position? position = MapsCubit.position;
                  List<Marker>? markers = MapsCubit.markers.toList();
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      GoogleMap(
                        onCameraMove: (position) {
                          log("position target ${position.target}");
                          setState(() {
                            latLng = position.target;
                            markers[0] = markers[0].copyWith(
                                positionParam: position.target
                            );
                          });
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position!.latitude, position.longitude),
                          zoom: 14.4746,
                        ),
                        mapType: MapType.satellite,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          setState((){
                            latLng = LatLng(position.latitude, position.longitude);
                            log("latLng $latLng");
                          });
                          _controller.complete(controller);
                          final marker = Marker(
                              markerId: const MarkerId('Here!'),
                              position:
                                  LatLng(position.latitude, position.longitude));
                          markers.add(marker);
                        },
                        compassEnabled: false,
                        myLocationButtonEnabled: true,
                      ),
                      Image.asset(
                        'assets/google-map-pin.png',
                        scale: 15,
                      )
                    ],
                  );
                }
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
               MapsAPI.getCurrentAddressFromLocation(
                      MapsCubit.position!.latitude,
                   MapsCubit.position!.latitude
               )
                  .then((model) {
                String? formattedAddress =
                    model?.results?.first.formattedAddress;
                Navigator.of(context).pop(formattedAddress);
              });
            },
            label: const Text('OK!', style: TextStyle(fontFamily: "SF")),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
