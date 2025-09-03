import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/masjid_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/masjid_card.dart';
import '../widgets/search_bar.dart' as custom_search;
import 'masjid_details_screen.dart';
import 'submit_masjid_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String _selectedTab = 'nearby';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      
      // Fetch nearby offices
      if (_selectedTab == 'nearby') {
        if (!mounted) return;
        Provider.of<MasjidProvider>(context, listen: false).fetchNearbyOffices(
          position.latitude,
          position.longitude,
          context,
        );
      }
    } catch (e) {
      'Error getting location';
      //print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masjid Locator'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubmitMasjidScreen()),
              );
            },
          ),
          PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
      },
    ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          custom_search.SearchBar(
            onSearch: (query) {
              setState(() {
              });
              Provider.of<MasjidProvider>(context, listen: false).filterOffices(query);
            },
          ),
          
          // Tab Selection
          Row(
            children: [
              _buildTabButton('Nearby', 'nearby'),
              _buildTabButton('By City', 'city'),
            ],
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String tab) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedTab = tab;
          });
          if (tab == 'nearby' && _currentPosition != null) {
            Provider.of<MasjidProvider>(context, listen: false).fetchNearbyOffices(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              context
            );
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: _selectedTab == tab ? Colors.blue : Colors.grey[200],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedTab == tab ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 'city') {
      return _buildCitySearch();
    } else {
      return _buildNearbyOffices();
    }
  }

  Widget _buildNearbyOffices() {
    final officeProvider = Provider.of<MasjidProvider>(context);

    if (officeProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (officeProvider.error.isNotEmpty) {
      return Center(child: Text(officeProvider.error));
    }

    if (officeProvider.offices.isEmpty) {
      return Center(child: Text('No Masjid found nearby'));
    }

    return ListView.builder(
      itemCount: officeProvider.offices.length,
      itemBuilder: (context, index) {
        final office = officeProvider.offices[index];
        return MasjidCard(
          office: office,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MasjidDetailScreen(office: office),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCitySearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Enter city name',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (city) {
              Provider.of<MasjidProvider>(context, listen: false).fetchOfficesByCity(city);
            },
          ),
        ),
        Expanded(child: _buildNearbyOffices()),
      ],
    );
  }
}