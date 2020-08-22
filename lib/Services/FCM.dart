import 'package:shared_preferences/shared_preferences.dart';


// Future<dynamic> backgroundMessageHandler(Map<String, dynamic> message) async {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];


//     if (data['type'] == 'inv') {
//       var prefs = await SharedPreferences.getInstance();
//       List<String> invitedToSwalf =
//           prefs.getStringList('invited') ?? List<String>();

//       invitedToSwalf.add(data['id']);

//       prefs.setStringList('invited', invitedToSwalf);
//     }
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }

//   // Or do other work.
// }

  