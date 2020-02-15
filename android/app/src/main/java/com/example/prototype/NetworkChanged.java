package com.example.prototype;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.util.Log;

public class NetworkChanged extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        try{
            ConnectivityManager cm = ((ConnectivityManager) context.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE));
            if(cm.getActiveNetworkInfo() == null || !cm.getActiveNetworkInfo().isConnected()){
                Log.d("NetworkChanged", "Network not connected");
                new Alarm().cancelAlarm(context.getApplicationContext());
                return;
            }
            Log.d("NetworkChanged", "Network Connected");
            new Alarm().setAlarm(context.getApplicationContext());
        }catch (Exception e){
            Log.e("NetworkChanged", "Error on network changed handler " + e);
        }
    }
}
