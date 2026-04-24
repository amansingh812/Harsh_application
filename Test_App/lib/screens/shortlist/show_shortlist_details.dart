/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/apis/get_school_setrvice.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../global/global_data.dart';

class ShowShortlistDetails extends StatefulWidget {
  final Shortlist school;

  const ShowShortlistDetails({super.key, required this.school});

  @override
  State<ShowShortlistDetails> createState() => _ShowShortlistDetails();
}

class _ShowShortlistDetails extends State<ShowShortlistDetails> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAllFacilities = false;
  List<Shortlist> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    */
/*  _searchController.addListener(() {
      setState(() {
        // Filter users based on search input
        filteredUsers = GlobalData().users.where((user) {
          final searchTerm = _searchController.text.toLowerCase();
          return user.name.toLowerCase().contains(searchTerm);
        }).toList();
      });
    }*//*

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Shortlist selectedUser = widget.school; // Use the passed User object

    return Scaffold(
      // backgroundColor: Color(0xFFE2E2E2),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.primary,
        ),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title:
            const Text('School Details', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Add share logic
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search logic
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Add cart logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              selectedUser.galleryImages[0],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    */
/*CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          NetworkImage(selectedUser.galleryImages[0]),
                    ),*//*

                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedUser.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 4),
                              Text(selectedUser.name),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: false,
                                    onChanged: (bool? value) {
                                      // Handle checkbox state change
                                    },
                                  ),
                                  Text('Compare'),
                                ],
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle shortlist logic
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite_border),
                                    SizedBox(width: 4),
                                    Text('Shortlist'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Other cards with selectedUser details...
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    */
/* Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.primary, // Blue color for the top border
                            width: 10.0, // Adjust the width as needed
                          ),
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        ),
                        color: Colors.white,
                      ),
                    ),*//*

                    Container(
                      padding: EdgeInsets.only(left: 10),
                      width: double.infinity,
                      // / height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Blue color for the top border
                            width: 10.0, // Adjust the width as needed
                          ),
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15.0),
                        ),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/school.png',
                                  // Display the category image
                                  width: 40,
                                  height: 40,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  'Key Stats',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 20,
                              thickness: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),

                      */
/*decoration: BoxDecoration(
                        color: Colors.green,
                      ),*//*

                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatItem(
                                    'Ownership', selectedUser.ownership),
                                _buildStatItem(
                                    'Board', selectedUser.boards.toUpperCase()),
                                _buildStatItem('Year of Establishment',
                                    selectedUser.yearOfEstablishment),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatItem(
                                    'Co-ed Status', selectedUser.coedStatus),
                                _buildStatItem(
                                    'Campus Size', selectedUser.builtInArea),
                                _buildStatItem('Views', selectedUser.views),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  width: double.infinity,
                  // / height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Blue color for the top border
                        width: 10.0, // Adjust the width as needed
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/school.png',
                              // Display the category image
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Academic Stats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20,
                          thickness: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAcademicStats('Classes Offered',
                                      selectedUser.classesOffered),
                                  _buildAcademicStats('Language of Instruction',
                                      selectedUser.languagesTaught),
                                  _buildAcademicStats('Academic Session',
                                      selectedUser.academicSession),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAcademicStats(
                                      'Medium', selectedUser.medium),
                                  _buildAcademicStats(
                                      'Timings', selectedUser.timings),
                                  _buildAcademicStats(
                                      'School Format', selectedUser.format),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  width: double.infinity,
                  // / height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Blue color for the top border
                        width: 10.0, // Adjust the width as needed
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/school.png',
                              // Display the category image
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Facilities',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20,
                          thickness: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: selectedUser.featureFacilities
                                    .take(_showAllFacilities
                                        ? selectedUser.featureFacilities.length
                                        : 2)
                                    .map((facility) => _buildFacilityItem(
                                        facility.name, facility.features))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllFacilities = !_showAllFacilities;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _showAllFacilities ? 'View Less' : 'View More',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  width: double.infinity,
                  // / height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Blue color for the top border
                        width: 10.0, // Adjust the width as needed
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/school.png',
                              // Display the category image
                              width: 40,
                              height: 40,
                            ),
                            Text(
                              'Address and Contact',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20,
                          thickness: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${selectedUser.address.address1}, ${selectedUser.address.address2}, ${selectedUser.address.pincode}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.mail, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedUser.email,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.open_in_browser,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _launchURL(selectedUser.website);
                                },
                                child: Text(
                                  selectedUser.website,
                                  style: new TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              onPressed: () {
                                _makePhoneCall(selectedUser.phoneNo);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                'Call Us',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAcademicStats(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facilityName, List<Feature> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          facilityName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...features
            .map((feature) => Row(
                  children: [
                    Icon(
                      feature.exist == 'Yes' ? Icons.check : Icons.cancel,
                      color: feature.exist == 'Yes' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(feature.name),
                  ],
                ))
            .toList(),
        SizedBox(height: 8),
      ],
    );
  }
}
*/
