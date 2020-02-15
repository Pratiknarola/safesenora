package com.example.prototype;

import android.Manifest;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class ForegroundLocationService extends Service implements
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener,
        LocationListener {

    private static final String TAG = ForegroundLocationService.class.getSimpleName();

    // the notification id for the foreground notification
    public static final int GPS_NOTIFICATION = 1;

    // the interval in seconds that gps updates are requested
    private static final int UPDATE_INTERVAL_IN_SECONDS = 15;
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

    // is this service currently running in the foreground?
    private boolean isForeground = false;

    // the google api client
    private GoogleApiClient googleApiClient;

    // the wakelock used to keep the app alive while the screen is off
    private PowerManager.WakeLock wakeLock;

    @Override
    public void onCreate() {
        super.onCreate();

        // create google api client
        googleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();

        // get a wakelock from the power manager
        final PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        if (!isForeground) {

            Log.v(TAG, "Starting the " + this.getClass().getSimpleName());

            startForeground(ForegroundLocationService.GPS_NOTIFICATION,
                    notifyUserThatLocationServiceStarted());
            isForeground = true;

            // connect to google api client
            googleApiClient.connect();

            // acquire wakelock
            wakeLock.acquire();
        }

        return START_REDELIVER_INTENT;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {

        Log.v(TAG, "Stopping the " + this.getClass().getSimpleName());

        stopForeground(true);
        isForeground = false;

        // disconnect from google api client
        googleApiClient.disconnect();

        // release wakelock if it is held
        if (null != wakeLock && wakeLock.isHeld()) {
            wakeLock.release();
        }

        super.onDestroy();
    }

    private LocationRequest getLocationRequest() {

        LocationRequest locationRequest = LocationRequest.create();

        // we always want the highest accuracy
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        // we want to make sure that we get an updated location at the specified interval
        locationRequest.setInterval(TimeUnit.SECONDS.toMillis(0));

        // this sets the fastest interval that the app can receive updates from other apps accessing
        // the location service. for example, if Google Maps is running in the background
        // we can update our location from what it sees every five seconds
        locationRequest.setFastestInterval(TimeUnit.SECONDS.toMillis(0));
        locationRequest.setMaxWaitTime(TimeUnit.SECONDS.toMillis(UPDATE_INTERVAL_IN_SECONDS));

        return locationRequest;
    }

    private Notification notifyUserThatLocationServiceStarted() {

        // pop up a notification that the location service is running
        //Intent notificationIntent = new Intent(this, NotificationActivity.class);
        //PendingIntent pendingIntent = PendingIntent.getActivity(this, 0,
        //        notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);

        final Notification.Builder builder = new Notification.Builder(this)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle("Prototype")
                .setContentText("Nikhar is nalayak")
                .setContentIntent(pendingIntent)
                .setWhen(System.currentTimeMillis());

        final Notification notification;
        notification = builder.build();

        return notification;
    }

    private boolean checkPermissions() {
        return  PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private void requestPermissions() {
        boolean shouldProvideRationale =
                ActivityCompat.shouldShowRequestPermissionRationale(new MainActivity(),
                        Manifest.permission.ACCESS_FINE_LOCATION);

        // Provide an additional rationale to the user. This would happen if the user denied the
        // request previously, but didn't check the "Don't ask again" checkbox.
        if (shouldProvideRationale) {
            Log.i(TAG, "Displaying permission rationale to provide additional context.");

        } else {
            Log.i(TAG, "Requesting permission");
            // Request permission. It's possible this can be auto answered if device policy
            // sets the permission in a given state or the user denied the permission
            // previously and checked "Never ask again".
            ActivityCompat.requestPermissions(new MainActivity(),
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    REQUEST_PERMISSIONS_REQUEST_CODE);
        }
    }


    @Override
    public void onConnected(@Nullable Bundle bundle) {

        try {
            if(!checkPermissions()){
                requestPermissions();
            }
            //LocationServices.getFusedLocationProviderClient(this).requestLocationUpdates(getLocationRequest(),);
            // request location updates from the fused location provider
            //LocationServices.FusedLocationApi.requestLocationUpdates(
            //        googleApiClient, getLocationRequest(), this);


        } catch (SecurityException securityException) {
            Log.e(TAG, "Exception while requesting location updates", securityException);
        }
    }

    @Override
    public void onConnectionSuspended(int i) {
        Log.i(TAG, "Google API Client suspended.");
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
        Log.e(TAG, "Failed to connect to Google API Client.");
    }

    @Override
    public void onLocationChanged(Location location) {
        Log.e(TAG, "onLocationChanged: " + location.toString());
        if(location != null){
            double lat = location.getLatitude();
            double lng = location.getLongitude();
            FirebaseFirestore db = FirebaseFirestore.getInstance();
            Map<String, Object> loc = new HashMap<>();
            loc.put("jLatitide", lat);
            loc.put("jLongitude", lng);

            db.collection("locations").add(loc)
                    .addOnSuccessListener(new OnSuccessListener<DocumentReference>() {
                        @Override
                        public void onSuccess(DocumentReference documentReference) {
                            System.out.println("DocumentSnapshot added with id: " + documentReference.getId());
                        }
                    }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    System.out.println("Error adding document " + e.toString());
                }
            });
        }
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }
}