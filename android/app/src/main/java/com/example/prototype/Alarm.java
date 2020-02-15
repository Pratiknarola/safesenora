package com.example.prototype;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class Alarm extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        context.sendBroadcast(new Intent("com.google.android.intent.action.MCS_HEARTBEAT"));
        context.sendBroadcast(new Intent("com.google.android.intent.action.GTALK_HEARTBEAT"));
        Log.d("Alarm", "Heartbeat sent");
    }

    public void setAlarm(Context context){
        cancelAlarm(context);
        NetworkInfo activeNetwork = ((ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE)).getActiveNetworkInfo();
        if(activeNetwork != null && activeNetwork.isConnected()){
            AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            int heartbeatValue = 5;
            am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(),(long) (60000 * heartbeatValue), PendingIntent.getBroadcast(context, 0, new Intent(context, Alarm.class), 0));
            Log.d("Alarm", "Alarm interval set to " + heartbeatValue + " minutes");
        }
    }
    public void cancelAlarm(Context context) {
        ((AlarmManager) context.getSystemService(Context.ALARM_SERVICE)).cancel(PendingIntent.getBroadcast(context, 0, new Intent(context, Alarm.class), 0));
        Log.d("Alarm", "Alarm cancelled");
    }
}
