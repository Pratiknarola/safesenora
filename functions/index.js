const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var levelData;

exports.offerTrigger =functions.firestore.document(
    'girl_user/{userId}/level_info/{userId}'
    ).onUpdate((snapshot, context) => {
    console.log("going to assign snap data to leveldata");
        levelData = snapshot.data();
    console.log("value assigned");
    console.log(userId);




        if(levelData.level1==true){

            //TODO make the level = false in database
            var name;

            /**********************************Name is getting here ***********************************/
            admin.firestore().document(`girl_user/${userId}/user_profile/${userId}`).get().then((profilesnap)=>{
                if(documentsnap.empty){
                        console.log("error getting the name of the currentuser");
                        }
                        else{
                        console.log(`got the name of the current user ${profilesnap.data().name}`);
                        name = profilesnap.data().name + profilesnap.data().surname;
                        }
            }).catch((err)=>{
                console.log("error occured in writing name query"+ err);
            })

            /*******************************************************************************************/

            admin.firestore().collection(`girl_user/${userId}/trusted_member`).get().then((snapshots)=>{
                    console.log("inside truted member list");
                    if(snapshots.empty){
                        console.log("No trusted member");
                    }
                    else
                    {
                        var tokens = [];
                        for(var member of snapshots.docs)
                        {

                            var trustedId=member.id;
                            admin.firestore().document(`protector/${trustedId}`).get().then((documentsnap)=>{
                                if(documentsnap.empty){
                                    console.log("error getting the token of the protector");
                                }
                                else{
                                    console.log(`adding the token ${documentsnap.data().NotifyToken} to list`);
                                    tokens.push(documentsnap.data().NotifyToken);
                                }
                            }).catch((err)=>{
                                console.log("error in writing the protector token query");
                            })
                        }
                        console.log('added tokens');
                        var payload = {
                          "notification" : {
                          "title": name + "pressed Level1",
                          "body": `tap to track ${name} details`,
                          "sound": "default"
                           },
                          "data" : {
                          "data1": "none",
                          "data2": "none"
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

                    }
            })

        }/*
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

    })

