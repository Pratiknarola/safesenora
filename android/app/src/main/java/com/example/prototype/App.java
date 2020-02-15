package com.example.prototype;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

import io.flutter.app.FlutterApplication;

public class App extends FlutterApplication {
    public static final String NOTIFICATION_CHANNEL_ID = "exampleServiceChannel";

    @Override
    public void onCreate() {
        System.out.println("I am in the app.java on create file");
        super.onCreate();

        createNotificationChannel();
    }

    private void createNotificationChannel() {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel serviceChannel = new NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "NotificationChannel",
                    NotificationManager.IMPORTANCE_HIGH
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
}
