const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { user } = require('firebase-functions/lib/providers/auth');
const { HttpsError } = require('firebase-functions/lib/providers/https');
admin.initializeApp();

const firestore = admin.firestore();
const fcm = admin.messaging();
const FieldValue = require('firebase-admin').firestore.FieldValue;

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });



exports.inviteUSer = functions.https.onCall(async (data, context) => {

    /*
    data keys: [salfhID, invitedID]
    */

    const salfhID = data.salfhID
    const invitedID = data.invitedID;

    const functionCallerID = context.auth.uid;


    var salfhData = await firestore.collection('Swalf').doc(salfhID).get();

    const adminID = salfhData.data()['adminID'];

    if (functionCallerID != adminID) {
        throw new functions.https.HttpsError('unauthorized', 'User is not authorized to perform the desired action, check your security rules to ensure they are correct');
    }


    await firestore.collection("Swalf").doc(salfhID).set({

        'usersInvited': FieldValue.arrayUnion(invitedID)

    }, { merge: true })

    condition = `'${invitedID}' in topics`;

    const payload = {
        notification: {
            title: "You are getting invited to this salfh", // TODO: change message
            body: salfhData['title'],
            //tag: context.params.salfhID
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhData.id,
            type: 'inv'

        },
        condition: condition
    };
    return admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));





})

exports.joinSalfh = functions.https.onCall(async (data, context) => {
    const salfhID = data.salfhID
    const color = data.color;
    const salfhRef = await firestore.collection('Swalf').doc(salfhID);
    const userRef = await firestore.collection('users').doc(context.auth.uid);
    try {

        return firestore.runTransaction(async function (transaction) {
            const snapshot = await transaction.get(salfhRef);
            let updatedData = {};
            if (snapshot.data()['colorsStatus'][color] == null) {
                updatedData = { colorsStatus: {}, colorsInOrder: FieldValue.arrayUnion(color) , 'usersInvited': arrayRemove(context.auth.uid)}
                updatedData.colorsStatus[color] = context.auth.uid;
            }
            transaction.set(salfhRef, updatedData, { merge: true });

            const newUserSwalf = {};
            newUserSwalf[salfhID] = color;
            transaction.set(userRef, { userSwalf: newUserSwalf }, { merge: true });
            return true;

        })
    } catch (e) {
        console.error(err);
        return false;

    }
})

exports.removeUser = functions.https.onCall(async (data, context) => {

    /* data: map{
        salfhID,
        ,color}
    */

    const salfhID = data.salfhID
    const color = data.color;
    console.log(data);
    console.log(salfhID);
    console.log(color);
    const salfhRef = await firestore.collection('Swalf').doc(salfhID);
    const userRef = await firestore.collection('users').doc(context.auth.uid);

    try {

        return firestore.runTransaction(async function (transaction) {



            let snapshot = await transaction.get(salfhRef);
            let updatedData = { colorsStatus: {} };

            console.log(snapshot.data());

            console.log(context.auth.uid);
            const colorsStatus = snapshot.data()['colorsStatus'];

            console.log(colorsStatus[color]);

            if (colorsStatus[color] == snapshot.data()['adminID'] && colorsStatus[color] == context.auth.uid) {
                var colorsInOrder = snapshot.data()['colorsInOrder']
                if (colorsInOrder.length == 0) {

                    return await deleteSalfh(salfhID, colorsStatus[color]); // not tested;  

                }
                else {
                    newAdminColor = colorsInOrder[0];
                    updatedData['colorsStatus'][color] = null;
                    updatedData['adminID'] = snapshot.data()[newAdminColor];
                    updatedData['colorsInOrder'] = FieldValue.arrayRemove(newAdminColor); // tested.
                }
            }

            else if (colorsStatus[color] == context.auth.uid) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);


            }
            else if (snapshot.data()['adminID'] == context.auth.uid) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);
            }
            else {
                throw "3rd else, Permission Denied";
            }

            transaction.set(salfhRef, updatedData, { merge: true });

            const deletedSalfh = {};
            deletedSalfh[`userSwalf.${salfhID}`] = FieldValue.delete();
            transaction.update(userRef, deletedSalfh);
            return true;
        });

    } catch (e) {
        console.error(e)
        return false;
    }


})


exports.onUserCreated = functions.firestore.document('/users/{userID}').onCreate((snapshot, context) => {
    const userID = context.params.userID;
    return firestore.collection('likes').doc(userID).create(
        {
            'likes': 0,
            'dislikes': 0,
            'usersVotes': {}
        }
    )
})

exports.onLikeOrDislike = functions.firestore.document('/likes/{likedUserID}').onUpdate((change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const likedUserID = context.params.likedUserID;

    console.log('this is before');
    console.log(before);
    console.log('this is after');
    console.log(after);

    console.log(typeof (after));

    if ((after.hasOwnProperty('likes') && after.likes != before.likes) || (after.hasOwnProperty('dislikes') && after.dislikes != before.dislikes)) {
        console.log('here-----------------------------------') // to avoid recursive calls.
        return;
    }
    else {
        const difference = getObjectDiff(before.usersVotes, after.usersVotes); // returns an array of the differnt keys between the two maps.
        console.log('size')

        afterSize = Object.keys(after.usersVotes).length;
        beforeSize = Object.keys(before.usersVotes).length

        console.log(afterSize);
        console.log(beforeSize);

        if (afterSize > beforeSize) { // a user has just liked or disliked

            if (after.usersVotes[difference[0]] == 'like') { // userLiked
                return firestore.collection("likes").doc(likedUserID).set({
                    'likes': FieldValue.increment(1)
                }, { merge: true });
            }
            else { // user disliked
                return firestore.collection("likes").doc(likedUserID).set({
                    'dislikes': FieldValue.increment(1)
                }, { merge: true });
            }

        }
        else if (afterSize == beforeSize) { // changed from like to dislike, or vice versa 

            if (after.usersVotes[difference[0]] == 'like') {
                return firestore.collection("likes").doc(likedUserID).set({
                    'likes': FieldValue.increment(1),
                    'dislikes': FieldValue.increment(-1)
                }, { merge: true });
            }
            else {
                return firestore.collection("likes").doc(likedUserID).set({
                    'dislikes': FieldValue.increment(1),
                    'likes': FieldValue.increment(-1),
                }, { merge: true });
            }
        }
        else { // user unliked or undisliked
            console.log(difference[0]);
            console.log(after.usersVotes[difference[0]]);
            if (before.usersVotes[difference[0]] == 'like') {
                return firestore.collection("likes").doc(likedUserID).set({
                    'likes': FieldValue.increment(-1)
                }, { merge: true });
            }
            else {
                return firestore.collection("likes").doc(likedUserID).set({
                    'dislikes': FieldValue.increment(-1)
                }, { merge: true });
            }
        }
    }



})

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
    firestore.collection('Swalf').doc(context.params.salfhID).update({ lastMessageSent: message });

    admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));
    return true;
    // return "yo";
});



const kColorNames = ["purple", "green", "yellow", "red", "blue"];
// makes changing color names in the future easier, if ever needed
// always use this when refering to colors.
// use example to get the first color:
// color: kOurColors[kColorNames[0]];
// exports.colorsStatusUpdated = functions.firestore.document('/Swalf/{salfhID}/userColors/userColors').onUpdate((change, context) => {
//     let colorChanged;
//     const before = change.before.data()
//     const after = change.after.data()
//     const adminID = after['adminID'];
//     for (const color in before) {
//         if (color == 'colorsInOrder' || color == 'adminID') {
//             continue;
//         }
//         if (before[color] != after[color]) {



//             colorChanged = color;
//             break;
//         }
//     }
//     console.log(before);
//     console.log(after);
//     if (after[colorChanged] == null) { // if user left salfh
//         const userID = before[colorChanged];

//         // if(userID == before['adminID']){
//         //     setNewAdmin(before) ;
//         // }


//         const changedDoc = { colorsStatus: {} };
//         changedDoc.colorsStatus[colorChanged] = null;
//         changedDoc.adminID = adminID;

//         // changedDoc.colorsInOrder = FieldValue.arrayRemove([colorChanged]);

//         firestore.collection('Swalf').doc(context.params.salfhID).set(changedDoc, { merge: true });
//         const deletedSalfh = {};
//         deletedSalfh[`userSwalf.${context.params.salfhID}`] = FieldValue.delete();
//         return firestore.collection('users').doc(userID).update(deletedSalfh);
//     }
//     else { // if user joined
//         const userID = after[colorChanged];
//         const changedDoc = { colorsStatus: {} }
//         changedDoc.colorsStatus[colorChanged] = userID;
//         //  changedDoc.colorsInOrder = FieldValue.arrayUnion([colorChanged]);
//         firestore.collection('Swalf').doc(context.params.salfhID).set(changedDoc, { merge: true });
//         const newUserSwalf = {};
//         newUserSwalf[context.params.salfhID] = colorChanged;
//         return firestore.collection('users').doc(userID).set({ userSwalf: newUserSwalf }, { merge: true });
//     }
// });

exports.salfhCreated = functions.firestore.document('/Swalf/{salfhID}').onCreate((snapshot, context) => {

    const salfh = snapshot.data();


    colorStatus = salfh.colorsStatus;
    colorStatus['colorsInOrder'] = [];


    let colorName;
    for (const color in salfh.colorsStatus) {
        if (salfh.colorsStatus[color] != null) {
            colorName = color;
            break;
        }
    }
    let userSwalf = {};
    userSwalf[context.params.salfhID] = colorName;
    firestore.collection('users').doc(salfh.adminID).set({
        userSwalf: userSwalf
    }, { merge: true });

    let chatRoomData = { lastLeftStatus: {}, typingStatus: {} };
    kColorNames.forEach(name => {
        chatRoomData.lastLeftStatus[name] = FieldValue.serverTimestamp();
        chatRoomData.typingStatus[name] = false;
    });
    firestore.collection("chatRooms").doc(context.params.salfhID).set(chatRoomData, { merge: true });

    const tags = salfh['tags'];
    console.log(snapshot.data());

    if (tags.length == 0) return;

    var condition = "";
    incrementTags(tags);
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
            body: salfh['title'],
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



function incrementTags(tags) {
    increment = FieldValue.increment(1);

    tags.forEach((tag) => {
        firestore.collection('tags').doc(tag).set({
            'tagName': tag,
            'tagCounter': increment,
            'searchKeys': stringKeys(tag)
        }, { merge: true });
    });
}

function stringKeys(tag) {
    var keys = [];

    for (i = 0; i < tag.length; i++) {
        keys.push(tag.substring(0, i + 1));
    }
    return keys;
}

function getObjectDiff(obj1, obj2) { // returns added,removed or modified keys in a list.
    const diff = Object.keys(obj1).reduce((result, key) => {
        if (!obj2.hasOwnProperty(key)) {
            result.push(key);
        } else if (obj1[key] == obj2[key]) {
            const resultKeyIndex = result.indexOf(key);
            result.splice(resultKeyIndex, 1);
        }
        return result;
    }, Object.keys(obj2));

    return diff;
}

async function deleteSalfh(salfhID, userID) {


    var batch = firestore.batch();




    var userColorsref = firestore.collection("Swalf").doc(salfhID).collection("userColors").doc('userColors');
    var salfhRef = firestore.collection("Swalf").doc(salfhID);
    var chatRoomRef = firestore.collection('chatRooms').doc(salfhID);
    // TODO: delete full subcollection of messages. 
    //var messageRef = firestore.collection('chatRooms').doc(salfh).collection('messages'); 
    var userRef = firestore.collection('users').doc(userID);

    batch.delete(userColorsref)
    batch.delete(salfhRef)
    batch.delete(chatRoomRef)
    batch.set(userRef, {
        'userSwalf': {
            [salfhID]: FieldValue.delete()
        }
    }, { merge: true });


    batch.commit().then(function () {
        return true;
    })
    return false;
}