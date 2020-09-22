import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/Services/ValidFirebaseStringConverter.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/MessageNotification.dart';
import 'package:solif/components/TagSearchSelectDialog.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/UserInterestScreen.dart';
import 'package:solif/models/Salfh.dart';

final firestore = FirebaseFirestore.instance;
final fcm = FirebaseMessaging();

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> interests = [];

  Future<void> getInterests() async {
    interests = (await firestore
            .collection('users')
            .doc(Provider.of<AppData>(context, listen: false).currentUserID)
            .get())
        .data()['subscribedTags']
        .cast<String>();
    if (mounted) {
      setState(() {});
      unsubscribeFromAllTags(interests);
    }
  }

  saveInterests(List<String> interests) async {
    bool isEnglish = Provider.of<Preferences>(context, listen: false).isEnglish;
    toast(isEnglish ? 'Saving interests...' : 'نحفظ اهتماماتك...');
    await firestore
        .collection('users')
        .doc(Provider.of<AppData>(context, listen: false).currentUserID)
        .set(
      {'subscribedTags': interests},
      SetOptions(merge: true),
    );
    toast(isEnglish ? 'Interests saved!' : 'تم!');
  }

  subscribeToAllTags() {
    for (var tag in interests) {
      fcm.subscribeToTopic(
          "${ValidFireBaseStringConverter.convertString(tag)}TAG");
    }
  }

  unsubscribeFromAllTags(List<String> interests) {
    for (var tag in interests) {
      fcm.unsubscribeFromTopic(
          "${ValidFireBaseStringConverter.convertString(tag)}TAG");
    }
  }

  onClose() {
    saveInterests(interests);
    unsubscribeFromAllTags(interests);
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isEnglish = Provider.of<Preferences>(context).isEnglish;
    return Theme(
      data: ThemeData(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        accentColor: kDarkModeTextColor87,
        primaryColor: kMainColor,
        toggleableActiveColor: kMainColor,
      ),
      child: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: SettingsList(
          backgroundColor: Color(0XFF121212),
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
                          return FutureBuilder<void>(
                              future: getInterests(),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return LoadingWidget(isEnglish
                                        ? 'Fetching interests...'
                                        : 'نجيب اهتماماتك...');
                                  case ConnectionState.done:
                                    return TagSearchSelectDialog(
                                      tags: interests,
                                      onAdd: (String tagName) {
                                        setState(() {
                                          interests.add(tagName);
                                        });
                                      },
                                      onRemove: (String tagName) {
                                        setState(() {
                                          interests.remove(tagName);
                                        });
                                      },
                                      onDispose: onClose,
                                      isInterests: true,
                                    );
                                  default:
                                    return LoadingWidget('');
                                }
                              });
                        }).then((val) => onClose());
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
                    print(FirebaseMessaging()
                        .getToken()
                        .then((value) => print(value)));
                    print(Provider.of<AppData>(context, listen: false)
                        .currentUserID);
                    showOverlayNotification(
                      (context) => MessageNotification(
                        title: 'sdifojsdf',
                        subtitle: 'dsiufhsd fiusdhf siudfh',
                        color: 'red',
                      ),
                    );
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
                SettingsTile.switchTile(
                  title: 'English',

                  //subtitle: 'English',
                  leading: Icon(Icons.satellite),
                  switchValue: isEnglish,

                  onToggle: (value) {
                    Provider.of<Preferences>(context, listen: false).language =
                        isEnglish ? 'ar' : 'en';
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
