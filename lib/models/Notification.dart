import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/NotificationTile.dart';

const notificationTypes = ['invite'];

List<NotificationTile> generateNotificationTiles(List<DocumentSnapshot> docs) {
  List<NotificationTile> notifications = [];
  for (DocumentSnapshot doc in docs) {
    if (notificationTypes.contains(doc['type'])) {
      notifications.add(
        NotificationTile(
          type: doc['type'],
          payload: doc['value'],
        ),
      );
    }
  }
  return notifications;
}
