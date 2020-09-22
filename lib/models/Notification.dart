import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/NotificationTile.dart';

const notificationTypes = ['invite'];

List<NotificationTile> generateNotificationTiles(List<DocumentSnapshot> docs) {
  List<NotificationTile> notifications = [];
  for (DocumentSnapshot doc in docs) {
    Map<String, dynamic> notifcationMap = doc.data();
    if (notificationTypes.contains(notifcationMap['type'])) {
      notifications.add(
        NotificationTile(
          type: notifcationMap['type'],
          payload: notifcationMap['value'],
        ),
      );
    }
  }
  return notifications;
}
