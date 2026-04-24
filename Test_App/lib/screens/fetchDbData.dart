/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'schoolData.dart';

class FetchdbData extends StatefulWidget {
  const FetchdbData({super.key});

  @override
  State<FetchdbData> createState() => _FetchdbDataState();
}

class _FetchdbDataState extends State<FetchdbData> {
  late ApiService apiService;
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'http://192.168.30.148:8084/buildapi-0.0.1-SNAPSHOT/AcmUserService');
    futureUser = apiService.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Local API Demo'),
      ),
      body: Center(
        child: FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No data found');
            } else {
              User user = snapshot.data!;
              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${user.level}'),
                        Text('Slug: ${user.slug}'),
                        Text('Email: ${user.email}'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text('Feature Facilities:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...user.featureFacilities.map((facility) {
                    return ExpansionTile(
                      title: Text(facility.name),
                      children: facility.features.map((feature) {
                        return ListTile(
                          leading: Image.network(feature.icon, width: 24, height: 24),
                          title: Text(feature.name),
                          trailing: Text(feature.exist),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
*/
