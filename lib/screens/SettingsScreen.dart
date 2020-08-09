import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/UserInterestScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLightTheme = true;
  String themeName = 'صباحي';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SettingsList(
          sections: [
            SettingsSection(
              title: 'شخصي',
              tiles: [
                SettingsTile(
                  title: 'اهتمامتي',

                  //subtitle: 'English',
                  leading: Icon(Icons.scatter_plot),

                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInterestScreen(),
                        ));
                  },
                ),
                SettingsTile(
                  title: 'نقاطي',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: () {
                    print('tapped');
                    HttpsCallable callable = CloudFunctions.instance
                        .getHttpsCallable(functionName: 'inviteUser');
                    callable.call({
                      'salfhID': 'SDFDS',
                      'invitedID': Provider.of<AppData>(context, listen: false)
                          .currentUserID
                    });
                  },
                ),
                SettingsTile(
                  title: 'new user',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: Provider.of<AppData>(context).reset,
                ),

                // SettingsTile.switchTile(
                //   title: 'Use fingerprint',
                //   leading: Icon(Icons.fingerprint),
                //   isLightTheme: value,
                //   onToggle: (bool value) {},
                // ),
              ],
            ),
            SettingsSection(
              title: 'المظهر',
              tiles: [
                SettingsTile.switchTile(
                  title: themeName,

                  //subtitle: 'English',
                  leading: Icon(Icons.satellite),
                  switchValue: !isLightTheme,

                  onToggle: (value) {
                    setState(() {
                      isLightTheme = !value;
                      isLightTheme ? themeName = 'صباحي' : themeName = 'مسائي';
                      print(value);
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
