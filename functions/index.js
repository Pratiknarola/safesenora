const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

let levelData, prevData, pressedLevel;

exports.offerTrigger = functions.firestore.document(
    'girl_user/{userId}/level_info/{Id}'
).onUpdate((snapshot, context) => {
    console.log("going to assign snap data to leveldata");
    levelData = snapshot.after.data();
    prevData = snapshot.before.data();


    //console.log(snapshot);
    console.log("value assigned");
    console.log(context.params.userId);
    console.log(context.params.Id);
    console.log("snapshot maharaj");
    console.log(snapshot);
    console.log(typeof snapshot);
    console.log("leveldata");
    console.log(levelData);
    console.log(typeof levelData);
    /* console.log("this is snapshot ref id");
     console.log(snapshot.ref.id);
     console.log('path');
     console.log(snapshot.ref.path);
     console.log("parent path");
     console.log(snapshot.ref.parent.path);
     console.log("parent id");
     console.log(snapshot.ref.parent.id);*/

    if (prevData.level1 !== levelData.level1)
        pressedLevel = "level1";
    else if (prevData.level2 !== levelData.level2)
        pressedLevel = "level2";
    else if (prevData.level3 !== levelData.level3)
        pressedLevel = "level3";


    console.log(pressedLevel);
    var userId = context.params.userId;


    //TODO make the level = false in database
    var fname, picture;
    var batterylevel;
let trusted_array=[];



    /**********************************Name is getting here ***********************************/
    admin.firestore().collection(`girl_user/${userId}/user_info`).get().then((profilesnap) => {
        if (profilesnap.isEmpty) {
            console.log("error getting the name of the currentuser");
        } else {
            profilesnap.forEach((prosnap) => {
                console.log(`got the name of the current user ${prosnap.data().name}`);
                fname = `${prosnap.data().name} ${prosnap.data().surname} `;
                picture = prosnap.data().picture;
                batterylevel = prosnap.data().battery;
            });

        }
    }).catch((err) => {
        console.log("error occured in writing name query" + err);
    });

    let trusted_array=[];

    // This thing sends notification.
    if((levelData.level1 === true && pressedLevel === 'level1') ||
        (levelData.level2 === true && pressedLevel === 'level2') ||
        (levelData.level3 === true && pressedLevel === 'level3')) {




        /*******************************************Tokens and notificaations are sending here************************************************/

        //let tokens = [];
        let payloadarray = [];
        admin.firestore().collection(`girl_user/${userId}/trusted_member`).get().then((snapshots) => {
            console.log("inside truted member list");
            if (snapshots.empty) {
                console.log("No trusted member");
            } else {
                var promises = [];
                for (var member of snapshots.docs) {

                    var trustedId = member.id;
                    trusted_array.push(trustedId);
                    const p = admin.firestore().doc(`protector/${trustedId}`).get();
                    promises.push(p);
                }
                return Promise.all(promises);
            }
        }).then((promisesnap) => {
            promisesnap.forEach((snap) => {
                //tokens.push(snap.data().NotifyToken);
                console.log(`token is ${snap.data().NotifyToken}`);


                let payload = {
                    "name":"Prototype",
                    "notification": {
                        "title": fname + "pressed " + pressedLevel,
                        "body": `Keep ur phone handy.\nTap to track ${fname} details`,
                        "image": picture
                    },
                    "data": {
                        "title": fname + "pressed " + pressedLevel,
                        "body": `Keep ur phone handy.\nTap to track ${fname} details`,
                        "image": picture,
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                        "level1": `${levelData.level1}`,
                        "level2": `${levelData.level2}`,
                        "level3": `${levelData.level3}`,
                        "pressedLevel": pressedLevel,
                        "battery": batterylevel,
                        "lastLocation": "none",
                        "girl_id": userId,
                        "girl_distance": "none"
                    },
                    "android": {
                        "priority": "high",
                        "notification": {
                            "color": "#FF4040",
                            "sound": "default",
                            "sticky": true,
                            "notification_priority": "priority_max",
                            "default_sound": true,
                            "default_vibrate_timings": true,
                            "default_light_settings": true,
                            "visibility": "public",
                            /*"light_settings": {
                                /!*"color": {
                                    "red": 255,
                                    "green": 0,
                                    "blue": 0,
                                    "alpha": 0
                                },*!/
                                "light_on_duration": "1.0s",
                                "light_off_duration": "1.0s"
                            }*/
                        },
                    },
                    "token": snap.data().NotifyToken
                };
                console.log("pusing payload");
                payloadarray.push(payload);
            });
            console.log('added tokens');

            console.log("after payload");
            console.log(payloadarray);


            return admin.messaging().sendAll(payloadarray).then((response) => {
                console.log("pushed them all");
            }).catch((err) => {
                console.log("error occured err " + err);
            });

            /*let promises =[];
            payloadarray.forEach((payload) => {

            });

            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                console.log("pushed them all");
            }).catch((err) => {
                console.log("error occured err " + err);
            });*/

        }).catch((err) => {
            console.log("error in writing the token getting query of trusted members");
        });

    }

    //This thing will be executed when level2 is pressed
    // this will send notifications to all those people who are in radius of 2 km

    if(levelData.level2 === true && pressedLevel === 'level2'){
        var level2PayloadArray = [];
        let l2promises = [];
        let ProtectorNotifyToken = new Map();
        let prouid;
        admin.firestore().doc(`girl_user/${userId}/location_info/${userId}`).get().then((snap) => {
            let gLastLocation = snap.data().last_location;
            admin.firestore().collection(`protector`).get().then((query_snap) => {
                query_snap.docs.forEach((doc_snap) => {
                    prouid = doc_snap.id;
                    ProtectorNotifyToken.set(`${prouid}`,`${doc_snap.data().NotifyToken}`);
                    const l2p = admin.firestore().doc(`protector/${prouid}/location_info/${prouid}`).get();
                    l2promises.push(l2p);
                });
                return Promise.all(l2promises);
            }).then((protectorsnaps)=>{
                protectorsnaps.forEach((snap)=>{
                    let pLastLocation=snap.data().last_location;
                    let distance;

                    function deg2rad(deg) {
                        const pi = 3.1415926535897932;
                        return deg * (pi / 180);
                    }

                    ((coord1=gLastLocation,coord2=pLastLocation) => {
                        const R = 6371; // Radius of the earth in km
                        let dLat = deg2rad(coord2.latitude - coord1.latitude);
                        let dLng = deg2rad(coord2.longitude - coord1.longitude);
                        let a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
                            Math.cos(deg2rad(coord1.latitude)) *
                            Math.cos(deg2rad(coord2.latitude)) *
                            Math.sin(dLng / 2) *
                            Math.sin(dLng / 2);
                        let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                        distance = R * c;
                    })();
                    console.log("Distance is " + distance.toString());

                    if(distance < 2.0 ){
                        //users.push(prouid);
                        let payload = {
                            "name":"Prototype",
                            "notification": {
                                "title": "ALERT! ALERT! Someone near you needs help!",
                                "body": "If you are willing to help please click on this notifcation and help her.",

                                "image": picture
                            },
                            "data": {
                                "title": "someone near you needs help",
                                "body": "if you are willing to help please open app and help her.",
                                "image": picture,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "level1": `${levelData.level1}`,
                                "level2": `${levelData.level2}`,
                                "level3": `${levelData.level3}`,
                                "pressedLevel": pressedLevel,
                                "battery": batterylevel,
                                "lastLocation": "none",
                                "girl_id": userId,
                                "girl_distance": "none"
                            },
                            "android": {
                                "priority": "high",
                                "notification": {
                                    "color": "#FF4040",
                                    "sound": "default",
                                    "sticky": true,
                                    "notification_priority": "priority_max",
                                    "default_sound": true,
                                    "default_vibrate_timings": true,
                                    "default_light_settings": true,
                                    "visibility": "public",
                                    /*"light_settings": {
                                        /!*"color": {
                                            "red": 255,
                                            "green": 0,
                                            "blue": 0,
                                            "alpha": 0
                                        },*!/
                                        "light_on_duration": "1.0s",
                                        "light_off_duration": "1.0s"
                                    }*/
                                },
                            },
                            "token": ProtectorNotifyToken.get(prouid)
                        };
                        console.log("pusing payload");
                        level2PayloadArray.push(payload);
                    }
                });
                console.log('added tokens of nearby users');
                console.log("after payload of nearby user");
                console.log(level2PayloadArray);
                return admin.messaging().sendAll(level2PayloadArray).then((response) => {
                    console.log("pushed them all to nearby users");
                }).catch((err) => {
                    console.log("error occured err " + err);
                });
            });

        })
    }

});
