import 'package:earthquake_app/App_Provider.dart';
import 'package:earthquake_app/helper_functions.dart';
import 'package:earthquake_app/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void didChangeDependencies() {
    Provider.of<appprovider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tremor Tracker',
        ),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            onPressed: _showsortingdialog,
            icon: Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => settingspage(),
              ),
            ),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<appprovider>(
        builder: (context, provider, child) => provider.hasdataloaded
            ? provider.earthquakeModel!.features!.isEmpty
                ? const Center(
                    child: Text('No record found'),
                  )
                : ListView.builder(
                    itemCount: provider.earthquakeModel!.features!.length,
                    itemBuilder: (context, index) {
                      final data = provider
                          .earthquakeModel!.features![index].properties!;
                      return ListTile(
                        title: Text(data.place ?? data.title ?? 'Unknown'),
                        subtitle: Text(getFormattedDateTime(
                            data.time!, 'EEE MMM dd yyyy hh:mm a')),
                        trailing: Chip(
                            avatar: data.alert == null
                                ? null
                                : CircleAvatar(
                                    backgroundColor:
                                        provider.getalertcolor(data.alert!),
                                  ),
                            label: Text('${data.mag}')),
                      );
                    })
            : Center(child: Text('Please wait')),
      ),
    );
  }

  void _showsortingdialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort by'),
        content: Consumer<appprovider>(
          builder: (context, provider, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radiogrp(
                value: 'magnitude',
                groupvalue: provider.orderby,
                label: 'Magnitude-Desc',
                onchange: (value) {
                  EasyLoading.show(status: '..Sorting..');
                  provider.setorder(value!);
                  EasyLoading.dismiss();
                },
              ),
              Radiogrp(
                value: 'magnitude-asc',
                groupvalue: provider.orderby,
                label: 'Magnitude-Asc',
                onchange: (value) {
                  EasyLoading.show(status: '..Sorting..');
                  provider.setorder(value!);
                  EasyLoading.dismiss();
                },
              ),
              Radiogrp(
                value: 'time',
                groupvalue: provider.orderby,
                label: 'Time-Desc',
                onchange: (value) {
                  EasyLoading.show(status: '..Sorting..');
                  provider.setorder(value!);
                  EasyLoading.dismiss();
                },
              ),
              Radiogrp(
                value: 'time-asc',
                groupvalue: provider.orderby,
                label: 'Time-Asc',
                onchange: (value) {
                  EasyLoading.show(status: '..Sorting..');
                  provider.setorder(value!);
                  EasyLoading.dismiss();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Radiogrp extends StatelessWidget {
  final String groupvalue;
  final String value;
  final String label;
  final Function(String?) onchange;

  const Radiogrp({
    super.key,
    required this.value,
    required this.groupvalue,
    required this.label,
    required this.onchange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: groupvalue,
          onChanged: onchange,
        ),
        Text(label),
      ],
    );
  }
}
