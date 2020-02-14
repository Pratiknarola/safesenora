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

    if((levelData.level1 === true && pressedLevel === 'level1') ||
        (levelData.level2 === true && pressedLevel === 'level2') ||
        (levelData.level3 === true && pressedLevel === 'level3')) {


        /**********************************Name is getting here ***********************************/
        admin.firestore().collection(`girl_user/${userId}/user_info`).get().then((profilesnap) => {
            if (profilesnap.isEmpty) {
                console.log("error getting the name of the currentuser");
            } else {
                profilesnap.forEach((prosnap) => {
                    console.log(`got the name of the current user ${prosnap.data().name}`);
                    fname = `${prosnap.data().name} ${prosnap.data().surname} `;
                    picture = prosnap.data().picture;
                });

            }
        }).catch((err) => {
            console.log("error occured in writing name query" + err);
        });

        /*******************************************Tokens and notificaations are sending here************************************************/

        let tokens = [];
        let payloadarray = [];
        admin.firestore().collection(`girl_user/${userId}/trusted_member`).get().then((snapshots) => {
            console.log("inside truted member list");
            if (snapshots.empty) {
                console.log("No trusted member");
            } else {
                var promises = [];
                for (var member of snapshots.docs) {

                    var trustedId = member.id;
                    const p = admin.firestore().doc(`protector/${trustedId}`).get();
                    promises.push(p);
                }
                return Promise.all(promises);
            }
        }).then((promisesnap) => {
            promisesnap.forEach((snap) => {
                tokens.push(snap.data().NotifyToken);
                let payload = {
                    //"name":"Prototype",
                    "notification": {
                        "title": fname + "pressed Level1",
                        "body": `Keep ur phone handy.\nTap to track ${fname} details`,
                        "image": picture
                    },
                    "data": {
                        "level1": `${levelData.level1}`,
                        "level2": `${levelData.level2}`,
                        "level3": `${levelData.level3}`,
                        "pressedLevel": pressedLevel,
                        "battery": levelData.battery,
                        "lastLocation": "none",
                        "girl_id": userId,
                        "girl_distance": "none"
                    },
                    "android": {
                        "priority": "high",
                        "notification": {
                            "color": "#FF4040",
                            "sound": "default",
                            // "click-action":""
                            "sticky": true,
                            "notification_priority": "priority_max",
                            "default_sound": true,
                            "default_vibrate_timings": true,
                            "default_light_settings": false,
                            "visibility": "public",
                            "light_settings": {
                                "color": {
                                    "red": 255,
                                    "green": 0,
                                    "blue": 0,
                                    "alpha": 0
                                },
                                "light_on_duration": "1.0s",
                                "light_off_duration": "1.0s"
                            }
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
    /* .then((documentsnap)=>{
     if(documentsnap.isEmpty){
         console.log("error getting the token of the protector");
     }
     else{
         console.log(`adding the token ${documentsnap.data().NotifyToken} to list`);
         token\s.push(documentsnap.data().NotifyToken);
     }
 }).catch((err)=>{
     console.log("error in writing the protector token query");
 });*/


    /*
    else if (levelData.level2==true) {

    }
    else if (levelData.level3==true) {

    }*/


    /*
            admin.firestore().collection('pushTokens').get().then((snapshots) => {
                var tokens = [];
                console.log("into pushtokens then");
                //print(tokens);
                if(snapshots.empty){
                    console.log('No Devices');
                }
                else
                {
                    for(var token of snapshots.docs){
                    console.log("devtoekns ");
                    console.log(token.data().devTokens);
                        tokens.push(token.data().devTokens);
                    }
                }
                console.log("before payload");
                var payload = {
                    "notification" :{
                        "title": "From" + msgData.offerName,
                        "body": "offer" + msgData.offerValue,
                        "sound": "default"

                    },
                    "data" : {
                        "offerName": msgData.offerName,
                        "offerValue": msgData.offerValue
                    }
                }
                 console.log("after payload");
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("pushed them all");
                            return "pratik";
                }).catch((err)=> {
                    console.log("error occured err " + err);
                    return "error pratik";
                })
            })

    */

});
