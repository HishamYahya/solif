const functions = require('firebase-functions');
const admin = require('firebase-admin')
admin.initializeApp();

const firestore = admin.firestore();
const fcm = admin.messaging();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.messageSent = functions.firestore.document('/chatRooms/{salfhID}/messages/{messageID}').onCreate((snapshot, context) => {
    const message = snapshot.data();
    const condition = `'${context.params.salfhID}' in topics && !('${message['userID']}' in topics)`;
    const payload = {
        notification: {
            title: message['color'],
            body: message['content'],
            tag: context.params.salfhID
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: context.params.salfhID
        },
        condition: condition
    };
    firestore.collection('Swalf').doc(context.params.salfhID).update({ lastMessageSentID: context.params.messageID });

    return admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));

    // return "yo";
});


exports.salfhWithTagCreated = functions.firestore.document('/Swalf/{salfhID}').onCreate((snapshot, context) => {

    const salfhWithTag = snapshot.data();
    const tags = salfhWithTag['tags'];
    console.log(snapshot.data());

    if (tags.length == 0) return;

    var condition = "";
    for (i in tags) {
        console.log(tags[i]);
        condition += `('${tags[i]}TAG' in topics) || `
    }
    condition = condition.substring(0, condition.length - 4);
    console.log(condition);
    // const condition = `'${context.params.tags[0]}' in topics || ${context.params.tags[1]}' in topics || ${context.params.tags[2]}' in topics`
    const payload = {
        notification: {
            title: "Check this salfh that matchs your interest", // TODO: change message
            body: salfhWithTag['title'],
            //tag: context.params.salfhID
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: context.params.salfhID
        },
        condition: condition
    };
    //firestore.collection('Swalf').doc(context.params.salfhID).update({ lastMessageSentID: context.params.messageID });

    return admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));

});