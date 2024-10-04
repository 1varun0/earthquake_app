import 'package:earthquake_app/App_Provider.dart';
import 'package:earthquake_app/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class settingspage extends StatefulWidget {
  const settingspage({super.key});

  @override
  State<settingspage> createState() => _settingspageState();
}

class _settingspageState extends State<settingspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green[800],
      ),
      body: Consumer<appprovider>(
        builder: (context, provider, child) => ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            SizedBox(
              height: 5,
            ),
            Text(
              'Time Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Start Time'),
                    subtitle: Text(provider.starttime!),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await selectdate();
                        if (date != null) {
                          provider.setstarttime(date);
                        }
                      },
                      icon: Icon(Icons.calendar_month),
                    ),
                  ),
                  ListTile(
                    title: Text('End Time'),
                    subtitle: Text(provider.endtime!),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await selectdate();
                        if (date != null) {
                          provider.setendtime(date);
                        }
                      },
                      icon: Icon(Icons.calendar_month),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.getearthquakedata();
                      showmsg(context, 'Changes updated');
                    },
                    child: Text('Update'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Location Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: SwitchListTile(
                title: Text(provider.city??'Your city is unknown'),
                subtitle: provider.city==null?null:Text('Earthquake data will be shown within ${provider.maxradiuskm} km radius from {$provider.city}',),
                value: provider.locationuse,
                onChanged: (value) async{
                  EasyLoading.show(status: 'Fetching location...');
                  await provider.setlocation(value);
                  EasyLoading.dismiss();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String?> selectdate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dt != null) {
      return getFormattedDateTime(dt.millisecondsSinceEpoch);
    }
    return null;
  }
}
