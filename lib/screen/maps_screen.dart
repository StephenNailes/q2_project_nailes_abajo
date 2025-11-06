import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _selectedLocation;
  LatLng? _currentLocation;
  bool _showingDirections = false;
  double? _distance;
  String? _duration;
  
  // Search & Filter states
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedFilters = {}; // 'Disposal Center', 'Refurbish Hub', 'Drop-off Point'
  bool _nearMeOnly = false;
  double _nearMeRadius = 5.0; // km
  String _sortBy = 'name'; // 'name', 'distance', 'rating'
  
  // Default location (Davao City, Philippines)
  static const LatLng _center = LatLng(7.1907, 125.4553);
  
  // Disposal location data
  final List<Map<String, dynamic>> _disposalLocations = [
    {
      'id': 'location1',
      'name': 'SM City Davao E-Waste Collection',
      'address': 'Ecoland Drive, Matina, Davao City',
      'position': const LatLng(7.0731, 125.6128),
      'type': 'Disposal Center',
      'color': BitmapDescriptor.hueGreen,
      'acceptedItems': ['Smartphones', 'Laptops', 'Tablets', 'Chargers', 'Batteries'],
      'openTime': '9:00 AM',
      'closeTime': '7:00 PM',
      'daysOpen': 'Mon - Sun',
    },
    {
      'id': 'location2',
      'name': 'Davao Tech Refurbish Hub',
      'address': 'Poblacion District, Davao City',
      'position': const LatLng(7.1907, 125.4553),
      'type': 'Refurbish Hub',
      'color': BitmapDescriptor.hueBlue,
      'acceptedItems': ['Laptops', 'Desktops', 'Monitors', 'Printers'],
      'openTime': '8:00 AM',
      'closeTime': '6:00 PM',
      'daysOpen': 'Mon - Sat',
    },
    {
      'id': 'location3',
      'name': 'Gaisano Mall Disposal Point',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'position': const LatLng(7.2906, 125.6803),
      'type': 'Drop-off Point',
      'color': BitmapDescriptor.hueOrange,
      'acceptedItems': ['Small Electronics', 'Cables', 'Chargers', 'Earphones'],
      'openTime': '10:00 AM',
      'closeTime': '9:00 PM',
      'daysOpen': 'Daily',
    },
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🗺️ MapsScreen: initState called');
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      debugPrint('🗺️ MapsScreen: Starting map initialization');
      
      // Add a small delay to ensure the widget is mounted
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) {
        debugPrint('🗺️ MapsScreen: Widget not mounted, aborting');
        return;
      }
      
      debugPrint('🗺️ MapsScreen: Loading disposal locations');
      _loadDisposalLocations();
      
      setState(() {
        _isLoading = false;
      });
      debugPrint('🗺️ MapsScreen: Initialization complete');
    } catch (e, stackTrace) {
      debugPrint('❌ MapsScreen: Error during initialization: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to initialize map: $e';
        });
      }
    }
  }

  void _loadDisposalLocations() {
    try {
      debugPrint('🗺️ MapsScreen: Adding markers');
      
      _markers.clear(); // Clear existing markers
      
      // Get filtered and sorted locations
      final filteredLocations = _getFilteredAndSortedLocations();
      
      for (var location in filteredLocations) {
        _markers.add(
          Marker(
            markerId: MarkerId(location['id']),
            position: location['position'],
            infoWindow: InfoWindow(
              title: location['name'],
              snippet: location['address'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(location['color']),
            onTap: () {
              debugPrint('🗺️ Marker tapped: ${location['name']}');
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
        );
      }
      
      // Re-add current location marker if available
      if (_currentLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(
              title: 'Your Location',
            ),
          ),
        );
      }
      
      debugPrint('🗺️ MapsScreen: Added ${_markers.length} markers');
    } catch (e) {
      debugPrint('❌ MapsScreen: Error loading markers: $e');
    }
  }
  
  /// Get filtered and sorted locations based on current filters
  List<Map<String, dynamic>> _getFilteredAndSortedLocations() {
    List<Map<String, dynamic>> filtered = List.from(_disposalLocations);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((location) {
        final query = _searchQuery.toLowerCase();
        final name = location['name'].toString().toLowerCase();
        final address = location['address'].toString().toLowerCase();
        final items = (location['acceptedItems'] as List<String>)
            .map((e) => e.toLowerCase())
            .join(' ');
        
        return name.contains(query) || 
               address.contains(query) || 
               items.contains(query);
      }).toList();
    }
    
    // Apply type filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((location) {
        return _selectedFilters.contains(location['type']);
      }).toList();
    }
    
    // Apply "Near Me" filter
    if (_nearMeOnly && _currentLocation != null) {
      filtered = filtered.where((location) {
        final distance = _calculateDistance(_currentLocation!, location['position']);
        return distance <= _nearMeRadius;
      }).toList();
    }
    
    // Sort locations
    filtered.sort((a, b) {
      if (_sortBy == 'distance' && _currentLocation != null) {
        final distA = _calculateDistance(_currentLocation!, a['position']);
        final distB = _calculateDistance(_currentLocation!, b['position']);
        return distA.compareTo(distB);
      } else if (_sortBy == 'name') {
        return a['name'].toString().compareTo(b['name'].toString());
      }
      // Default to name if no valid sort
      return 0;
    });
    
    return filtered;
  }
  
  /// Get current user location
  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('📍 Requesting location permission');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location in your device settings.');
      }
      
      // Check permission using Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable in settings.');
      }
      
      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      // Reload markers to include current location
      _loadDisposalLocations();
      
      debugPrint('✅ Current location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
      
      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get your location: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  /// Calculate distance between two points in kilometers
  double _calculateDistance(LatLng start, LatLng end) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((end.latitude - start.latitude) * p) / 2 +
        cos(start.latitude * p) * cos(end.latitude * p) *
        (1 - cos((end.longitude - start.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
  
  /// Draw route line between current location and destination
  Future<void> _showDirections(Map<String, dynamic> location) async {
    try {
      debugPrint('🗺️ Showing directions to: ${location['name']}');
      
      // Get current location if not already available
      if (_currentLocation == null) {
        await _getCurrentLocation();
        if (_currentLocation == null) {
          throw Exception('Could not determine your location');
        }
      }
      
      final destination = location['position'] as LatLng;
      
      // Calculate distance
      final distance = _calculateDistance(_currentLocation!, destination);
      _distance = distance;
      
      // Estimate duration (assuming average speed of 30 km/h in city)
      final hours = distance / 30;
      final minutes = (hours * 60).round();
      _duration = minutes < 60 
          ? '$minutes min' 
          : '${(minutes / 60).floor()} hr ${minutes % 60} min';
      
      // Create polyline
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: [_currentLocation!, destination],
        color: const Color(0xFF2ECC71),
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );
      
      setState(() {
        _polylines.clear();
        _polylines.add(polyline);
        _showingDirections = true;
      });
      
      // Adjust camera to show both points
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentLocation!.latitude < destination.latitude 
              ? _currentLocation!.latitude 
              : destination.latitude,
          _currentLocation!.longitude < destination.longitude 
              ? _currentLocation!.longitude 
              : destination.longitude,
        ),
        northeast: LatLng(
          _currentLocation!.latitude > destination.latitude 
              ? _currentLocation!.latitude 
              : destination.latitude,
          _currentLocation!.longitude > destination.longitude 
              ? _currentLocation!.longitude 
              : destination.longitude,
        ),
      );
      
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
      
      debugPrint('✅ Directions shown: ${distance.toStringAsFixed(2)} km, $_duration');
    } catch (e) {
      debugPrint('❌ Error showing directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not show directions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Clear directions
  void _clearDirections() {
    setState(() {
      _polylines.clear();
      _showingDirections = false;
      _distance = null;
      _duration = null;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    debugPrint('🗺️ MapsScreen: Map created callback');
    _mapController = controller;
  }

  @override
  void dispose() {
    debugPrint('🗺️ MapsScreen: Disposing');
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🗺️ MapsScreen: Building widget (loading: $_isLoading, error: $_errorMessage)');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('🗺️ MapsScreen: Back button pressed');
            context.go('/home');
          },
        ),
        title: const Text(
          'Find Disposal Locations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentLocation != null ? Icons.my_location : Icons.location_searching,
              color: _currentLocation != null ? Colors.white : Colors.white70,
            ),
            onPressed: _getCurrentLocation,
            tooltip: 'Get My Location',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Map',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint('🗺️ MapsScreen: Retry button pressed');
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _initializeMap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              debugPrint('🗺️ MapsScreen: GoogleMap onMapCreated callback');
              _onMapCreated(controller);
            },
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: _currentLocation != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
            trafficEnabled: false,
            liteModeEnabled: false, // Full interactive mode
          ),
          
          // Search bar at top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search locations, items...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2ECC71)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _loadDisposalLocations();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _loadDisposalLocations();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter button
                      _buildActionChip(
                        label: 'Filters',
                        icon: Icons.tune,
                        isSelected: _selectedFilters.isNotEmpty || _nearMeOnly,
                        onTap: () {
                          _showFilterBottomSheet();
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      // Type filter chips
                      _buildFilterChip(
                        label: 'Disposal',
                        icon: Icons.delete_outline,
                        type: 'Disposal Center',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Refurbish',
                        icon: Icons.build_circle_outlined,
                        type: 'Refurbish Hub',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Drop-off',
                        icon: Icons.location_on_outlined,
                        type: 'Drop-off Point',
                      ),
                      const SizedBox(width: 8),
                      
                      // Near Me chip
                      _buildActionChip(
                        label: 'Near Me',
                        icon: Icons.near_me,
                        isSelected: _nearMeOnly,
                        onTap: () {
                          if (_currentLocation == null) {
                            _getCurrentLocation().then((_) {
                              setState(() {
                                _nearMeOnly = !_nearMeOnly;
                                _loadDisposalLocations();
                              });
                            });
                          } else {
                            setState(() {
                              _nearMeOnly = !_nearMeOnly;
                              _loadDisposalLocations();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      // Sort dropdown chip
                      _buildSortChip(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results count badge
          if (_searchQuery.isNotEmpty || _selectedFilters.isNotEmpty || _nearMeOnly)
            Positioned(
              top: 140,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_getFilteredAndSortedLocations().length} location${_getFilteredAndSortedLocations().length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          // Location details card at bottom (shown when marker selected)
          if (_selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name and close button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLocation!['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getLocationTypeColor(_selectedLocation!['type'])
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedLocation!['type'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getLocationTypeColor(_selectedLocation!['type']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedLocation = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Color(0xFF2ECC71),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLocation!['address'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Operating hours
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Color(0xFF2ECC71),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedLocation!['daysOpen']}: ${_selectedLocation!['openTime']} - ${_selectedLocation!['closeTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Accepted items
                    const Text(
                      'Accepted Items:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_selectedLocation!['acceptedItems'] as List<String>)
                          .map((item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2ECC71),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Directions buttons
                    if (!_showingDirections) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('🗺️ Showing directions to: ${_selectedLocation!['name']}');
                            _showDirections(_selectedLocation!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text(
                            'Show Directions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Show distance and duration
                      if (_distance != null && _duration != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.straighten, color: Color(0xFF2ECC71)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_distance!.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                  const Text(
                                    'Distance',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.access_time, color: Color(0xFF2ECC71)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _duration!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                  const Text(
                                    'Duration',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _clearDirections,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text(
                            'Clear Directions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getLocationTypeColor(String type) {
    switch (type) {
      case 'Disposal Center':
        return const Color(0xFF2ECC71);
      case 'Refurbish Hub':
        return const Color(0xFF3498DB);
      case 'Drop-off Point':
        return const Color(0xFFF39C12);
      default:
        return Colors.grey;
    }
  }
  
  /// Build filter chip for location types
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required String type,
  }) {
    final isSelected = _selectedFilters.contains(type);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedFilters.remove(type);
            } else {
              _selectedFilters.add(type);
            }
            _loadDisposalLocations();
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build action chip (for filters, near me)
  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build sort dropdown chip
  Widget _buildSortChip() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showSortOptions();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                _sortBy == 'distance' 
                    ? 'Distance' 
                    : _sortBy == 'name' 
                        ? 'Name' 
                        : 'Rating',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Show sort options bottom sheet
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Name', 'name', Icons.sort_by_alpha),
              if (_currentLocation != null)
                _buildSortOption('Distance', 'distance', Icons.near_me),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  /// Build individual sort option
  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF2ECC71) : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF2ECC71))
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _loadDisposalLocations();
        });
        Navigator.pop(context);
      },
    );
  }
  
  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedFilters.clear();
                            _nearMeOnly = false;
                          });
                          setState(() {
                            _loadDisposalLocations();
                          });
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Color(0xFF2ECC71)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Location Type Section
                  const Text(
                    'Location Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModalFilterChip(
                        label: 'Disposal Center',
                        type: 'Disposal Center',
                        setModalState: setModalState,
                      ),
                      _buildModalFilterChip(
                        label: 'Refurbish Hub',
                        type: 'Refurbish Hub',
                        setModalState: setModalState,
                      ),
                      _buildModalFilterChip(
                        label: 'Drop-off Point',
                        type: 'Drop-off Point',
                        setModalState: setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Near Me Section
                  const Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Show only locations near me'),
                    subtitle: Text('Within ${_nearMeRadius.toStringAsFixed(0)} km'),
                    value: _nearMeOnly,
                    activeColor: const Color(0xFF2ECC71),
                    onChanged: (value) {
                      if (_currentLocation == null && value) {
                        Navigator.pop(context);
                        _getCurrentLocation().then((_) {
                          setState(() {
                            _nearMeOnly = value;
                            _loadDisposalLocations();
                          });
                        });
                      } else {
                        setModalState(() {
                          _nearMeOnly = value;
                        });
                        setState(() {
                          _loadDisposalLocations();
                        });
                      }
                    },
                  ),
                  if (_nearMeOnly) ...[
                    Slider(
                      value: _nearMeRadius,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '${_nearMeRadius.toStringAsFixed(0)} km',
                      activeColor: const Color(0xFF2ECC71),
                      onChanged: (value) {
                        setModalState(() {
                          _nearMeRadius = value;
                        });
                        setState(() {
                          _loadDisposalLocations();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  /// Build filter chip in modal
  Widget _buildModalFilterChip({
    required String label,
    required String type,
    required StateSetter setModalState,
  }) {
    final isSelected = _selectedFilters.contains(type);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          if (selected) {
            _selectedFilters.add(type);
          } else {
            _selectedFilters.remove(type);
          }
        });
        setState(() {
          _loadDisposalLocations();
        });
      },
      selectedColor: const Color(0xFF2ECC71).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF2ECC71),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[300]!,
      ),
    );
  }
}
