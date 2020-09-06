import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/UserInterestScreen.dart';
import 'package:solif/models/Salfh.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    return Theme(
      data: ThemeData(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        accentColor: kDarkModeTextColor87,
        primaryColor: kMainColor,
        toggleableActiveColor: kMainColor,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SettingsList(
          backgroundColor: kDarkModeDarkGrey,
          sections: [
            SettingsSection(
              title: 'شخصي',
              tiles: [
                SettingsTile(
                  title: 'اهتمامتي',

                  //subtitle: 'English',
                  leading: Icon(Icons.scatter_plot),

                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(child: UserInterestScreen());
                        });
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return  UserInterestScreen();
                    // }));
                  },
                ),
                SettingsTile(
                  title: 'نقاطي',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: () {
                    print('tapped');
                    print(Provider.of<AppData>(context, listen: false)
                        .currentUserID);
                  },
                ),
                SettingsTile(
                  title: 'new user',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: Provider.of<AppData>(context).reset,
                ),
                SettingsTile(
                  title: 'invite self',
                  leading:
                      Icon(Icons.signal_cellular_connected_no_internet_4_bar),
                  onTap: () {
                    HttpsCallable callable = CloudFunctions.instance
                        .getHttpsCallable(functionName: 'testNotification');
                    Future.delayed(Duration(seconds: 4))
                        .then((value) => callable.call());
                  },
                ),

                // SettingsTile.switchTile(
                //   title: 'Use fingerprint',
                //   leading: Icon(Icons.fingerprint),
                //   isLightTheme: value,
                //   onToggle: (bool value) {},
                // ),
                SettingsTile(
                    title: 'Generate Error',
                    leading: Icon(Icons.error),
                    onTap: () {
                      throw ("generated error 1");
                    }),
              ],
            ),
            SettingsSection(
              title: 'المظهر',
              tiles: [
                SettingsTile.switchTile(
                  title: 'مسائي',

                  //subtitle: 'English',
                  leading: Icon(Icons.satellite),
                  switchValue: darkMode,

                  onToggle: (value) {
                    Provider.of<Preferences>(context, listen: false).darkMode =
                        value;
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
