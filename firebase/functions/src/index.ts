import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { CallableContext, HttpsError } from "firebase-functions/lib/providers/https";
// import { user } from 'firebase-functions/lib/providers/auth';
// import { HttpsError } from 'firebase-functions/lib/providers/https';
// import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";
admin.initializeApp();

const firestore = admin.firestore();
// const fcm = admin.messaging();
const FieldValue = admin.firestore.FieldValue;

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

type Color = 'purple' | 'green' | 'yellow' | 'red' | 'blue';

const UnauthenticatedException = new HttpsError('unauthenticated', 'User is not authorized to perform the desired action, check your security rules to ensure they are correct');
enum ColorNames {
    "purple" = "purple",
    "green" = "green",
    "yellow" = "yellow",
    "blue" = "blue",
    "red" = "red",
}
enum NotificationType {
    'INVITE' = 'invite',

}

const HexColors = {
    'purple': '#540d6e',
    'green': '#2EBD7D',
    'yellow': '#ECB22E',
    'red': '#E01E5A',
    'blue': '#36C5F0'
};


const kColorNames: Array<Color> = [ColorNames.blue, ColorNames.green, ColorNames.purple, ColorNames.red, ColorNames.yellow];



exports.inviteUser = functions.https.onCall(async (data, context) => {

    /*
    data keys: [salfhID, userToAddID]
    */

    if (context.auth === undefined) throw UnauthenticatedException;

    const salfhID = data.salfhID
    const userToAddID = data.userToAddID;


    const functionCallerID = context.auth.uid;


    const salfhData = (await firestore.collection('Swalf').doc(salfhID).get()).data();

    if (salfhData === undefined) throw new Error("Document not found");

    const adminID = salfhData.adminID;
    if (functionCallerID !== adminID) {
        throw UnauthenticatedException;
    }

    const notificationData = { "value": salfhID, 'type': 'invite', 'timeSent': FieldValue.serverTimestamp };
    console.log("userToAddID" + userToAddID);
    console.log("ourdata" + notificationData);

    await firestore.collection("users").doc(userToAddID).collection('notifications').doc('notifications').set({ 'usersInvited': FieldValue.arrayUnion(notificationData) }, { merge: true });


    const condition: string = `'${userToAddID}' in topics`;

    const dataPayload = {
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhData.id,
            type: 'inv'

        },
        condition: condition
    };
    const notification = {
        nootification: {
            title: "You are getting invited to this salfh", // TODO: change message
            body: salfhData['title'],
        },
        condition: condition
    };
    await admin.messaging().send(dataPayload).then(value => console.log(value)).catch(err => console.log(err));

    await admin.messaging().send(notification).then(value => console.log(value)).catch(err => console.log(err));

    return true;

})

enum ServerMessageType {
    INVITE = 'invite',
    JOIN = 'join',
    LEAVE = 'leave',
    KICK = 'kick'
}

interface ServerMessage {
    color: string,
    fromServer: true,
    type: ServerMessageType,
    timeSent: admin.firestore.FieldValue
}

exports.joinSalfh = functions.https.onCall(async (data: {
    salfhID: string,
    color: string,
    userToAddID?: string | null,
}, context) => {
    if (!context.auth) {
        throw UnauthenticatedException;
    }
    const { salfhID, color, userToAddID } = data;
    console.log(userToAddID);
    const callerID: string = context.auth.uid;
    let snapshot: any;
    let serverMessage: ServerMessage;

    const salfhRef = firestore.collection('Swalf').doc(salfhID);
    try {

        return firestore.runTransaction(async function (transaction) {
            snapshot = await transaction.get(salfhRef);
            let userRef;
            if (!userToAddID) {
                userRef = firestore.collection('users').doc(callerID);
            }
            else if (snapshot.data()?.adminID === callerID) {
                userRef = firestore.collection('users').doc(userToAddID);
            }
            else {
                throw new HttpsError('invalid-argument', 'Invalid input');
            }

            const fcmToken: string = (await transaction.get(userRef)).data()?.fcmToken;

            if (Object.values(snapshot.data()?.colorsStatus).includes(userRef.id)) {
                throw new HttpsError('already-exists', 'User already in salfh');
            }


            let updatedData = {} as any;
            if (snapshot.data()?.colorsStatus[color] === null) {
                updatedData = { colorsInOrder: FieldValue.arrayUnion(color), 'usersInvited': FieldValue.arrayRemove(userRef.id) }
                updatedData[`colorsStatus.${color}`] = userRef.id;
            }
            transaction.update(salfhRef, updatedData);

            const newUserSwalf = {} as any;

            newUserSwalf[`userSwalf.${salfhID}`] = color;

            transaction.update(userRef, newUserSwalf);
            return fcmToken;

        }).then(async (fcmToken) => {
            if (userToAddID !== null) {
                const id = userToAddID as string;
                serverMessage = {
                    color,
                    type: ServerMessageType.INVITE,
                    fromServer: true,
                    timeSent: FieldValue.serverTimestamp()
                }
                await sendAndSaveNotification(id, salfhID, snapshot.data());
            }
            else {
                serverMessage = {
                    color,
                    type: ServerMessageType.JOIN,
                    fromServer: true,
                    timeSent: FieldValue.serverTimestamp()
                }


            }
            console.log(serverMessage);
            await firestore.collection('chatRooms').doc(salfhID).collection('messages').add(serverMessage);
            try {
                await admin.messaging().subscribeToTopic(fcmToken, salfhID);
            } catch (e) {
                throw new HttpsError('not-found', 'invalid token', e);
            }
            return true;
        });
    } catch (err) {
        console.error(err);
        return false;

    }
})

exports.removeUser = functions.https.onCall(async (data, context) => {

    /* data: map{
        salfhID,
        ,color}
    */
    if (!context.auth) {
        throw UnauthenticatedException;
    }

    const salfhID = data.salfhID
    const color = data.color;
    console.log(data);
    console.log(salfhID);
    console.log(color);
    const salfhRef = firestore.collection('Swalf').doc(salfhID);
    const userRef = firestore.collection('users').doc(context.auth.uid);

    let isGoingToBeDeleted = false;

    let serverMessage: ServerMessage;

    try {

        return firestore.runTransaction(async function (transaction) {



            const snapshotData = (await transaction.get(salfhRef)).data();
            const fcmToken: string = (await transaction.get(userRef)).data()?.fcmToken;

            const updatedData = { colorsStatus: {} as any } as any;

            if (snapshotData === undefined) {
                throw new Error("Error loading document");
            }

            console.log(snapshotData);

            console.log(context.auth?.uid);
            const colorsStatus = snapshotData.colorsStatus;

            console.log(colorsStatus[color]);

            if (colorsStatus[color] === snapshotData?.adminID && colorsStatus[color] === context.auth?.uid) {
                const colorsInOrder = snapshotData.colorsInOrder;
                if (colorsInOrder.length === 0) {
                    isGoingToBeDeleted = true;
                    deleteSalfh(salfhID, colorsStatus[color], transaction);
                }
                else {
                    const newAdminColor = colorsInOrder[0];
                    updatedData['colorsStatus'][color] = null;
                    updatedData['adminID'] = snapshotData[newAdminColor];
                    updatedData['colorsInOrder'] = FieldValue.arrayRemove(newAdminColor); // tested.
                }
            }

            else if (colorsStatus[color] === context.auth?.uid) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);
                serverMessage = {
                    color,
                    type: ServerMessageType.LEAVE,
                    fromServer: true,
                    timeSent: FieldValue.serverTimestamp()
                }


            }
            else if (snapshotData['adminID'] === context.auth?.uid) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);
                serverMessage = {
                    color,
                    type: ServerMessageType.KICK,
                    fromServer: true,
                    timeSent: FieldValue.serverTimestamp()
                }
            }
            else {
                throw new Error("3rd else, Permission Denied");
            }

            transaction.set(salfhRef, updatedData, { merge: true });

            const deletedSalfh = {} as any;
            deletedSalfh[`userSwalf.${salfhID}`] = FieldValue.delete();
            transaction.update(userRef, deletedSalfh);
            return fcmToken;
        }).then(async (fcmToken) => {
            if (!isGoingToBeDeleted) {
                await firestore.collection('chatRooms').doc(salfhID).collection('messages').add(serverMessage);
                try {
                    await admin.messaging().unsubscribeFromTopic(fcmToken, salfhID);
                } catch (e) {
                    throw new HttpsError('not-found', 'invalid token', e);
                }
            }


        });

    } catch (e) {
        console.error(e)
        return false;
    }


})


exports.onUserCreated = functions.firestore.document('/users/{userID}').onCreate((_snapshot, context) => {
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

    if ((after.hasOwnProperty('likes') && after.likes !== before.likes) || (after.hasOwnProperty('dislikes') && after.dislikes !== before.dislikes)) {
        console.log('here-----------------------------------') // to avoid recursive calls.
        return false;
    }
    else {
        const difference = getObjectDiff(before.usersVotes, after.usersVotes); // returns an array of the differnt keys between the two maps.
        console.log('size')

        const afterSize = Object.keys(after.usersVotes).length;
        const beforeSize = Object.keys(before.usersVotes).length

        console.log(afterSize);
        console.log(beforeSize);

        if (afterSize > beforeSize) { // a user has just liked or disliked

            if (after.usersVotes[difference[0]] === 'like') { // userLiked
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
        else if (afterSize === beforeSize) { // changed from like to dislike, or vice versa 

            if (after.usersVotes[difference[0]] === 'like') {
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
            if (before.usersVotes[difference[0]] === 'like') {
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

exports.testNotification = functions.https.onCall(async (data, context) => {
    // const condition: string = `'${context.auth?.uid}' in topics`;

    // const notification: admin.messaging.Message = {
    //     notification: {
    //         title: "\uD83D\uDFE3 Test notification", // TODO: change message
    //         body: 'Test notification body',
    //     },
    //     android: {
    //         notification: {
    //             title: 'Test notification',
    //             color: HexColors['blue'],
    //             icon: 'blue_dot',
    //             imageUrl: 'https://i.ibb.co/wzGLgWV/Ellipse-2.png',
    //         }
    //     },
    //     data: {
    //         click_action: 'FLUTTER_NOTIFICATION_CLICK',
    //         type: 'message',
    //     },

    //     condition: condition
    // };

    const condition = `'${context.auth?.uid}' in topics`;
    const payload: admin.messaging.Message = {
        notification: {
            title: 'Salfh title',
            body: `${EMOJIS['red']}: hsduf asidufh asiduf `,
        },
        android: {
            notification: {
                body: 'osidjf sdoifj sdoif ',
                color: HexColors['red'],
                icon: 'red_dot',
            }
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            salfhID: 'sp86WNVj6KUh5ALzolci',
            type: 'message'
        },
        condition: condition
    };

    await admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));

    return true;

});

const EMOJIS = {
    'red': '🔴',
    'blue': '🔵',
    'purple': '🟣',
    'green': '🟢',
    'yellow': '🟡'

}

interface Message {
    color: Color,
    userID: string,
    serverTimeSent: admin.firestore.Timestamp,
    salfhTitle: string
}

interface UserMessage extends Message {
    content: string,
}

interface ImageMessage extends Message {
    imageURL: string
}

exports.messageSent = functions.firestore.document('/chatRooms/{salfhID}/messages/{messageID}')
    .onCreate((snapshot, context) => {
        let message;
        try {
            message = snapshot.data() as UserMessage | ImageMessage;
        } catch (e) {
            throw new HttpsError('cancelled', 'server message', e)
        }
        const content = 'content' in message ? message.content : 'Sent an Image';
        const condition = `'${context.params.salfhID}' in topics && !('${message['userID']}' in topics)`;
        // const condition = `'${context.params.salfhID}' in topics`;
        const payload: admin.messaging.Message = {
            notification: {
                title: message.salfhTitle,
                body: `${EMOJIS[message.color]}: ${content}`,
            },
            android: {
                notification: {
                    body: content,
                    color: HexColors[message.color],
                    icon: `${message.color}_dot`,
                }
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                salfhID: context.params.salfhID,
                color: message.color,
                type: 'message'
            },
            condition: condition
        };
        // tslint:disable-next-line: no-floating-promises
        firestore.collection('Swalf').doc(context.params.salfhID).update({ lastMessageSent: message });
        admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));
        return true;


        // return "yo";
    });




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
//         if (color === 'colorsInOrder' || color === 'adminID') {
//             continue;
//         }
//         if (before[color] != after[color]) {



//             colorChanged = color;
//             break;
//         }
//     }
//     console.log(before);
//     console.log(after);
//     if (after[colorChanged] === null) { // if user left salfh
//         const userID = before[colorChanged];

//         // if(userID === before['adminID']){
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
class ColorsStatus {
    red?: string;
    green?: string;
    blue?: string;
    purple?: string;
    yellow?: string;
}

function getColorsStatus(adminID: string): ColorsStatus {
    const colorsStatus = {} as any;
    for (const colorName of kColorNames) {
        colorsStatus[colorName] = null;
    }
    const color: Color = kColorNames[Math.floor(Math.random() * 5)];
    colorsStatus[color] = adminID;
    return colorsStatus;
}

exports.createSalfh = functions.https.onCall(async (data: {
    title: string,
    visible?: boolean,
    tags?: Array<string>,
    FCM_tags?: Array<string>
}, context: CallableContext) => {
    if (!context.auth) {
        throw UnauthenticatedException;
    }
    const salfhRef: admin.firestore.DocumentReference = firestore.collection('Swalf').doc();
    const colorsStatus = getColorsStatus(context.auth.uid);
    await salfhRef.create({
        title: data.title,
        visible: data.visible ?? true,
        tags: data.tags ?? [],
        timeCreated: FieldValue.serverTimestamp(),
        lastMessageSent: {},
        colorsInOrder: [],
        colorsStatus: colorsStatus,
        adminID: context.auth.uid
    })
    const userSwalf = {} as {
        [id: string]: Color
    };
    userSwalf[salfhRef.id] = (Object.keys(colorsStatus) as Array<Color>).find(key => colorsStatus[key] === context.auth?.uid) ?? 'blue';
    // tslint:disable-next-line: no-floating-promises
    await firestore.collection('users').doc(context.auth.uid).set({
        userSwalf: userSwalf
    }, { merge: true });

    await firestore.collection('users').doc(context.auth.uid).get().then((document) => {
        admin.messaging().subscribeToTopic(document.data()?.fcmToken, salfhRef.id).catch();
    })

    const chatRoomData = { lastLeftStatus: {} as any, typingStatus: {} as any };
    kColorNames.forEach(name => {
        chatRoomData.lastLeftStatus[name] = FieldValue.serverTimestamp();
        chatRoomData.typingStatus[name] = false;
    });
    await firestore.collection("chatRooms").doc(salfhRef.id).set(chatRoomData, { merge: true });

    const FCM_tags = data.FCM_tags ?? [];
    const tags = data.tags ?? [];


    if (!tags || tags.length === 0) return { salfhID: salfhRef.id };

    let condition = "";
    incrementTags(tags, FCM_tags);
    for (const i in FCM_tags) {
        console.log(FCM_tags[i]);
        condition += `('${FCM_tags[i]}TAG' in topics) || `
    }
    condition = condition.substring(0, condition.length - 4);
    console.log(condition);
    // const condition = `'${context.params.tags[0]}' in topics || ${context.params.tags[1]}' in topics || ${context.params.tags[2]}' in topics`
    const payload = {
        notification: {
            title: "Check this salfh that matchs your interest", // TODO: change message
            body: data.title,
            //tag: context.params.salfhID
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhRef.id
        },
        condition: condition
    };

    admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));
    return { salfhID: salfhRef.id };
})

interface UserDocumentData {
    id: string,
    userSwalf: {
        [id: string]: Color
    },
    mutedSwalf: string[],
    fcmToken: string
}

exports.toggleMute = functions.https.onCall(async (data: { salfhID: string }, context) => {
    if (!context.auth)
        throw UnauthenticatedException;
    const { salfhID } = data;
    const userRef = firestore.collection('users').doc(context.auth.uid);
    await firestore.runTransaction(async (transaction) => {
        const document = (await transaction.get(userRef) as admin.firestore.DocumentSnapshot<UserDocumentData>).data();
        console.log(document);
        if (!document)
            throw new HttpsError('data-loss', 'user document returned null')
        console.log(Object.keys(document.userSwalf));
        if (Object.keys(document.userSwalf).indexOf(salfhID) === -1) {
            throw new HttpsError('permission-denied', 'user not in salfh');
        }
        const isMuted: boolean = document.mutedSwalf.indexOf(salfhID) !== -1;
        if (isMuted) {
            transaction.update(userRef, { 'mutedSwalf': FieldValue.arrayRemove(salfhID) });
        }
        else {
            transaction.update(userRef, { 'mutedSwalf': FieldValue.arrayUnion(salfhID) });
        }
        return {
            fcmToken: document.fcmToken,
            isMuted: !isMuted

        };
    }).then(async val => {
        if (val.isMuted)
            await admin.messaging().unsubscribeFromTopic(val.fcmToken, salfhID);
        else
            await admin.messaging().subscribeToTopic(val.fcmToken, salfhID);
        return true;
    }).catch(e => { throw new HttpsError('internal', 'error in transaction', e); });
})

// exports.salfhCreated = functions.firestore.document('/Swalf/{salfhID}').onCreate((snapshot, context) => {

//     const salfh = snapshot.data();


//     const colorStatus = salfh.colorsStatus;
//     colorStatus['colorsInOrder'] = [];


//     let colorName;
//     for (const color in salfh.colorsStatus) {
//         if (salfh.colorsStatus[color] !== null) {
//             colorName = color;
//             break;
//         }
//     }
//     const userSwalf = {} as any;
//     userSwalf[context.params.salfhID] = colorName;
//     // tslint:disable-next-line: no-floating-promises
//     firestore.collection('users').doc(salfh.adminID).set({
//         userSwalf: userSwalf
//     }, { merge: true });

//     const chatRoomData = { lastLeftStatus: {} as any, typingStatus: {} as any };
//     kColorNames.forEach(name => {
//         chatRoomData.lastLeftStatus[name] = FieldValue.serverTimestamp();
//         chatRoomData.typingStatus[name] = false;
//     });
//     // tslint:disable-next-line: no-floating-promises
//     firestore.collection("chatRooms").doc(context.params.salfhID).set(chatRoomData, { merge: true });

//     const tags = salfh['tags'];
//     console.log(snapshot.data());

//     if (tags.length === 0) return;

//     let condition = "";
//     incrementTags(tags);
//     for (const i in tags) {
//         console.log(tags[i]);
//         condition += `('${tags[i]}TAG' in topics) || `
//     }
//     condition = condition.substring(0, condition.length - 4);
//     console.log(condition);
//     // const condition = `'${context.params.tags[0]}' in topics || ${context.params.tags[1]}' in topics || ${context.params.tags[2]}' in topics`
//     const payload = {
//         notification: {
//             title: "Check this salfh that matchs your interest", // TODO: change message
//             body: salfh['title'],
//             //tag: context.params.salfhID
//         },
//         data: {
//             click_action: 'FLUTTER_NOTIFICATION_CLICK',
//             id: context.params.salfhID
//         },
//         condition: condition
//     };



//     return admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));

// });



function incrementTags(tags: Array<string>, FCM_tags: Array<string>) {
    const increment = FieldValue.increment(1);

    let i: number = 0;

    tags.forEach((tag: string) => {
        // tslint:disable-next-line: no-floating-promises
        firestore.collection('tags').doc(FCM_tags[i++]).set({
            'tagName': tag,
            'tagCounter': increment,
            'searchKeys': stringKeys(tag)
        }, { merge: true });
    });
}

function stringKeys(tag: string) {
    const keys = [];

    for (let i = 0; i < tag.length - 2; i++) {
        keys.push(tag.substring(0, i + 1));
    }
    return keys;
}

function getObjectDiff(obj1: any, obj2: any) { // returns added,removed or modified keys in a list.
    const diff = Object.keys(obj1).reduce((result, key) => {
        if (!obj2.hasOwnProperty(key)) {
            result.push(key);
        } else if (obj1[key] === obj2[key]) {
            const resultKeyIndex = result.indexOf(key);
            result.splice(resultKeyIndex, 1);
        }
        return result;
    }, Object.keys(obj2));

    return diff;
}

function deleteSalfh(salfhID: string, userID: string, transaction: FirebaseFirestore.Transaction) {


    const userColorsref = firestore.collection("Swalf").doc(salfhID).collection("userColors").doc('userColors');
    const salfhRef = firestore.collection("Swalf").doc(salfhID);
    const chatRoomRef = firestore.collection('chatRooms').doc(salfhID);
    // TODO: delete full subcollection of messages. 
    //var messageRef = firestore.collection('chatRooms').doc(salfh).collection('messages'); 
    const userRef = firestore.collection('users').doc(userID);

    transaction.delete(userColorsref)
    transaction.delete(salfhRef)
    transaction.delete(chatRoomRef)
    transaction.set(userRef, {
        'userSwalf': {
            [salfhID]: FieldValue.delete()
        }
    }, { merge: true });

}
async function sendAndSaveNotification(userToAddID: string, salfhID: string, data: any) {
    const notificationData = { "value": { "id": salfhID, "title": data['title'] }, 'type': NotificationType.INVITE, 'time': FieldValue.serverTimestamp() };
    console.log("userToAddID" + userToAddID);
    console.log("ourdata" + notificationData);

    await firestore.collection("users").doc(userToAddID).collection('notifications').doc().set(notificationData);

    const condition: string = `'${userToAddID}' in topics`;

    const dataPayload = {
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhID,
            type: 'inv'

        },
        condition: condition
    };
    const notification = {
        notification: {
            title: "You are getting invited to this salfh", // TODO: change message
            body: data['title'],
        },
        condition: condition
    };
    await admin.messaging().send(dataPayload).then(value => console.log(value)).catch(err => console.log(err));

    await admin.messaging().send(notification).then(value => console.log(value)).catch(err => console.log(err));

}