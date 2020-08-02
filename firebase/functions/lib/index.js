"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/lib/providers/https");
// import { user } from 'firebase-functions/lib/providers/auth';
// import { HttpsError } from 'firebase-functions/lib/providers/https';
// import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";
admin.initializeApp();
const firestore = admin.firestore();
// const fcm = admin.messaging();
const FieldValue = admin.firestore.FieldValue;
var ColorNames;
(function (ColorNames) {
    ColorNames["purple"] = "purple";
    ColorNames["green"] = "green";
    ColorNames["yellow"] = "yellow";
    ColorNames["blue"] = "blue";
    ColorNames["red"] = "red";
})(ColorNames || (ColorNames = {}));
const kColorNames = [ColorNames.blue, ColorNames.green, ColorNames.purple, ColorNames.red, ColorNames.yellow];
exports.inviteUSer = functions.https.onCall(async (data, context) => {
    /*
    data keys: [salfhID, invitedID]
    */
    if (context.auth === undefined)
        throw new Error("User not authenticated");
    const salfhID = data.salfhID;
    const invitedID = data.invitedID;
    const functionCallerID = context.auth.uid;
    const salfhData = await (await firestore.collection('Swalf').doc(salfhID).get()).data();
    if (salfhData === undefined)
        throw new Error("Document not found");
    const adminID = salfhData.adminID;
    if (functionCallerID !== adminID) {
        throw new functions.https.HttpsError('unauthenticated', 'User is not authorized to perform the desired action, check your security rules to ensure they are correct');
    }
    // await firestore.collection("Swalf").doc(salfhID).set({  'usersInvited': FieldValue.arrayUnion(invitedID) }, { merge: true })
    // in case sharedprefrence method doesn't work uncomment. 
    const condition = `'${invitedID}' in topics`;
    const payload = {
        notification: {
            title: "You are getting invited to this salfh",
            body: salfhData['title'],
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhData.id,
            type: 'inv'
        },
        condition: condition
    };
    return admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));
});
exports.joinSalfh = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new Error("User not authenticated");
    }
    const salfhID = data.salfhID;
    const color = data.color;
    const salfhRef = await firestore.collection('Swalf').doc(salfhID);
    const userRef = await firestore.collection('users').doc(context.auth.uid);
    try {
        return firestore.runTransaction(async function (transaction) {
            var _a, _b, _c;
            const snapshot = await transaction.get(salfhRef);
            let updatedData = {};
            updatedData.colorsStatus = {};
            if (((_a = snapshot.data()) === null || _a === void 0 ? void 0 : _a.colorsStatus[color]) === null) {
                updatedData = { colorsStatus: {}, colorsInOrder: FieldValue.arrayUnion(color), 'usersInvited': FieldValue.arrayRemove((_b = context.auth) === null || _b === void 0 ? void 0 : _b.uid) };
                updatedData.colorsStatus[color] = (_c = context.auth) === null || _c === void 0 ? void 0 : _c.uid;
            }
            transaction.set(salfhRef, updatedData, { merge: true });
            const newUserSwalf = {};
            newUserSwalf[salfhID] = color;
            transaction.set(userRef, { userSwalf: newUserSwalf }, { merge: true });
            return true;
        });
    }
    catch (err) {
        console.error(err);
        return false;
    }
});
exports.removeUser = functions.https.onCall(async (data, context) => {
    /* data: map{
        salfhID,
        ,color}
    */
    if (!context.auth) {
        throw new https_1.HttpsError('unauthenticated', "You are not logged in");
    }
    const salfhID = data.salfhID;
    const color = data.color;
    console.log(data);
    console.log(salfhID);
    console.log(color);
    const salfhRef = firestore.collection('Swalf').doc(salfhID);
    const userRef = firestore.collection('users').doc(context.auth.uid);
    try {
        return firestore.runTransaction(async function (transaction) {
            var _a, _b, _c, _d;
            const snapshotData = (await transaction.get(salfhRef)).data();
            const updatedData = { colorsStatus: {} };
            if (snapshotData === undefined) {
                throw new Error("Error loading document");
            }
            console.log(snapshotData);
            console.log((_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid);
            const colorsStatus = snapshotData.colorsStatus;
            console.log(colorsStatus[color]);
            if (colorsStatus[color] === (snapshotData === null || snapshotData === void 0 ? void 0 : snapshotData.adminID) && colorsStatus[color] === ((_b = context.auth) === null || _b === void 0 ? void 0 : _b.uid)) {
                const colorsInOrder = snapshotData.colorsInOrder;
                if (colorsInOrder.length === 0) {
                    deleteSalfh(salfhID, colorsStatus[color], transaction); // not tested;  
                }
                else {
                    const newAdminColor = colorsInOrder[0];
                    updatedData['colorsStatus'][color] = null;
                    updatedData['adminID'] = snapshotData[newAdminColor];
                    updatedData['colorsInOrder'] = FieldValue.arrayRemove(newAdminColor); // tested.
                }
            }
            else if (colorsStatus[color] === ((_c = context.auth) === null || _c === void 0 ? void 0 : _c.uid)) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);
            }
            else if (snapshotData['adminID'] === ((_d = context.auth) === null || _d === void 0 ? void 0 : _d.uid)) {
                updatedData['colorsStatus'][color] = null;
                updatedData['colorsInOrder'] = FieldValue.arrayRemove(color);
            }
            else {
                throw new Error("3rd else, Permission Denied");
            }
            transaction.set(salfhRef, updatedData, { merge: true });
            const deletedSalfh = {};
            deletedSalfh[`userSwalf.${salfhID}`] = FieldValue.delete();
            transaction.update(userRef, deletedSalfh);
            return true;
        });
    }
    catch (e) {
        console.error(e);
        return false;
    }
});
exports.onUserCreated = functions.firestore.document('/users/{userID}').onCreate((_snapshot, context) => {
    const userID = context.params.userID;
    return firestore.collection('likes').doc(userID).create({
        'likes': 0,
        'dislikes': 0,
        'usersVotes': {}
    });
});
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
        console.log('here-----------------------------------'); // to avoid recursive calls.
        return false;
    }
    else {
        const difference = getObjectDiff(before.usersVotes, after.usersVotes); // returns an array of the differnt keys between the two maps.
        console.log('size');
        const afterSize = Object.keys(after.usersVotes).length;
        const beforeSize = Object.keys(before.usersVotes).length;
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
});
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
}
function getColorsStatus(adminID) {
    const colorsStatus = {};
    for (const colorName of kColorNames) {
        colorsStatus[colorName] = null;
    }
    const color = kColorNames[Math.floor(Math.random() * 5)];
    colorsStatus[color] = adminID;
    return colorsStatus;
}
exports.createSalfh = functions.https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!context.auth) {
        throw new https_1.HttpsError('unauthenticated', 'You are not logged in');
    }
    const salfhRef = firestore.collection('Swalf').doc();
    const colorsStatus = getColorsStatus(context.auth.uid);
    await salfhRef.create({
        title: data.title,
        visible: (_a = data.visible) !== null && _a !== void 0 ? _a : true,
        tags: (_b = data.tags) !== null && _b !== void 0 ? _b : [],
        timeCreated: FieldValue.serverTimestamp(),
        lastMessageSent: {},
        colorsInOrder: [],
        colorsStatus: colorsStatus,
        adminID: context.auth.uid
    });
    const userSwalf = {};
    userSwalf[salfhRef.id] = colorsStatus[(_c = Object.keys(colorsStatus).find(key => { var _a; return colorsStatus[key] === ((_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid); })) !== null && _c !== void 0 ? _c : 'blue'];
    // tslint:disable-next-line: no-floating-promises
    await firestore.collection('users').doc(context.auth.uid).set({
        userSwalf: userSwalf
    }, { merge: true });
    const chatRoomData = { lastLeftStatus: {}, typingStatus: {} };
    kColorNames.forEach(name => {
        chatRoomData.lastLeftStatus[name] = FieldValue.serverTimestamp();
        chatRoomData.typingStatus[name] = false;
    });
    await firestore.collection("chatRooms").doc(salfhRef.id).set(chatRoomData, { merge: true });
    const tags = data.tags;
    if (!tags || tags.length === 0)
        return { salfhID: salfhRef.id };
    let condition = "";
    incrementTags(tags);
    for (const i in tags) {
        console.log(tags[i]);
        condition += `('${tags[i]}TAG' in topics) || `;
    }
    condition = condition.substring(0, condition.length - 4);
    console.log(condition);
    // const condition = `'${context.params.tags[0]}' in topics || ${context.params.tags[1]}' in topics || ${context.params.tags[2]}' in topics`
    const payload = {
        notification: {
            title: "Check this salfh that matchs your interest",
            body: data.title,
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: salfhRef.id
        },
        condition: condition
    };
    admin.messaging().send(payload).then(value => console.log(value)).catch(err => console.log(err));
    return { salfhID: salfhRef.id };
});
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
function incrementTags(tags) {
    const increment = FieldValue.increment(1);
    tags.forEach((tag) => {
        // tslint:disable-next-line: no-floating-promises
        firestore.collection('tags').doc(tag).set({
            'tagName': tag,
            'tagCounter': increment,
            'searchKeys': stringKeys(tag)
        }, { merge: true });
    });
}
function stringKeys(tag) {
    const keys = [];
    for (let i = 0; i < tag.length; i++) {
        keys.push(tag.substring(0, i + 1));
    }
    return keys;
}
function getObjectDiff(obj1, obj2) {
    const diff = Object.keys(obj1).reduce((result, key) => {
        if (!obj2.hasOwnProperty(key)) {
            result.push(key);
        }
        else if (obj1[key] === obj2[key]) {
            const resultKeyIndex = result.indexOf(key);
            result.splice(resultKeyIndex, 1);
        }
        return result;
    }, Object.keys(obj2));
    return diff;
}
function deleteSalfh(salfhID, userID, transaction) {
    const userColorsref = firestore.collection("Swalf").doc(salfhID).collection("userColors").doc('userColors');
    const salfhRef = firestore.collection("Swalf").doc(salfhID);
    const chatRoomRef = firestore.collection('chatRooms').doc(salfhID);
    // TODO: delete full subcollection of messages. 
    //var messageRef = firestore.collection('chatRooms').doc(salfh).collection('messages'); 
    const userRef = firestore.collection('users').doc(userID);
    transaction.delete(userColorsref);
    transaction.delete(salfhRef);
    transaction.delete(chatRoomRef);
    transaction.set(userRef, {
        'userSwalf': {
            [salfhID]: FieldValue.delete()
        }
    }, { merge: true });
}
//# sourceMappingURL=index.js.map