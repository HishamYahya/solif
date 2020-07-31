import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/UserInterestScreen.dart';
import 'package:solif/models/Salfh.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLightTheme = true;
  String themeName = 'صباحي';
  @override
  Widget build(BuildContext context) {
    String invitedID = "2AryTgBqu7TDS3QkVxSUH5JJuyz1";
    String salfhID = "XD";
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
                ),
                SettingsTile(
                  title: 'new user',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: Provider.of<AppData>(context).reset,
                ),

                SettingsTile(
                    title: 'invite $invitedID',
                    leading: Icon(Icons.airline_seat_individual_suite),
                    onTap: () {
                      inviteUserToSalfh(
                        invitedID: invitedID,
                        salfhID: salfhID,
                      );
                    }),
                    
                    SettingsTile(
                    title: 'print my invites',
                    leading: Icon(Icons.airline_seat_individual_suite),
                    onTap: () async {

                      print('waiting for prefs'); 
                      var prefs = await SharedPreferences.getInstance();
                      List<String> listOfInvites = prefs.getStringList('invited') ?? [];
                      print("list: $listOfInvites");  
                      
                    }),

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
