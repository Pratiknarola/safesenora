const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var levelData;

exports.offerTrigger =functions.firestore.document(
    'girl_user/{userId}/level_info/{Id}'
    ).onUpdate((snapshot, context) => {
    console.log("going to assign snap data to leveldata");
    levelData = snapshot.after.data();
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




     var userId=context.params.userId;


        if(levelData.level1 === true) {

            //TODO make the level = false in database
            var fname;

            /**********************************Name is getting here ***********************************/
              admin.firestore().collection(`girl_user/${userId}/user_info`).get().then((profilesnap)=>{
                   if(profilesnap.isEmpty){
                          console.log("error getting the name of the currentuser");
                   }
                   else{
                          profilesnap.forEach((prosnap)=>{
                              console.log(`got the name of the current user ${prosnap.data().name}`);
                              fname = `${prosnap.data().name} + ${prosnap.data().surname}`;
                          });

                          }
              }).catch((err)=>{
                  console.log("error occured in writing name query"+ err);
              });

            /*******************************************Tokens and notificaations are sending here************************************************/

            let tokens = [];
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
                });
                console.log('added tokens');
                const payload = {
                    "notification": {
                        "title": fname + "pressed Level1",
                        "body": `tap to track ${fname} details`,
                        "sound": "default"
                    },
                    "data": {
                        "data1": "none",
                        "data2": "none"
                    }
                };
                console.log("after payload");
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("pushed them all");
                }).catch((err) => {
                    console.log("error occured err " + err);
                });

            }).catch((err) => {
                console.log("error in writing the token getting query of trusted members");
            });


            /* .then((documentsnap)=>{
             if(documentsnap.isEmpty){
                 console.log("error getting the token of the protector");
             }
             else{
                 console.log(`adding the token ${documentsnap.data().NotifyToken} to list`);
                 tokens.push(documentsnap.data().NotifyToken);
             }
         }).catch((err)=>{
             console.log("error in writing the protector token query");
         });*/


        }



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

