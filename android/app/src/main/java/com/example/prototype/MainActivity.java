package com.example.prototype;


import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.ComponentName;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.google.android.gms.location.ActivityRecognitionClient;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;

import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.GeoPoint;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;



public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "platformlocation";
    private FusedLocationProviderClient fusedLocationProviderClient;
    private static final String TAG = MainActivity.class.getSimpleName();
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;
    private LocationRequest mLocationRequest;
    private SettingsClient mSettingsClient;
    private LocationSettingsRequest mLocationSettingsRequest;
    private static final int REQUEST_CHECK_SETTINGS = 0x1;
    private ActivityRecognitionClient mActivityRecognitionClient;
    private LocationCallback mLocationCallback;
    public Alarm alarm;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getLastLocation")) {
                        System.out.println("Inside getLastLocatio function");
                        System.out.println(call.arguments);
                        getLastLoc(call.argument("userid"), call.argument("role"));
                    } else if (call.method.equals("startForegroundService")) {
                        System.out.println("Got in start location");
                        System.out.println(call.arguments);
                        startLocationService("start");
                    } else if (call.method.equals("stopForegroundService")) {
                        System.out.println("Stopping service");
                        System.out.println(call.arguments);
                        startLocationService("stop");
                    } else if (call.method.equals("startJob")) {
                        System.out.println("got into startjob");
                        System.out.println(call.arguments);
                        scheduleJob(call.argument("userid"));
                    } else if (call.method.equals("stopJob")) {
                        System.out.println("got into stopJob");
                        System.out.println(call.arguments);
                        cancelJob();
                    } else if (call.method.equals("sendBroadcast")) {
                        System.out.println("Got in sendBroadcast");
                        sendHeartBeat();
                        System.out.println("sendBroadcast complete");
                    } else if (call.method.equals("setAlarm")) {
                        System.out.println("inside of setAlarm");
                        this.alarm = new Alarm();
                        setAlarm();
                    }
                    else if (call.method.equals("stopAlarm")){
                        System.out.println("inside of stopAlarm");
                        if(alarm != null) alarm.cancelAlarm(MainActivity.this.getApplicationContext());
                        System.out.println("Alarm cancelled");
                    }

                });

    }

    private void setAlarm() {
        this.alarm.setAlarm(MainActivity.this.getApplicationContext());
    }


    private void sendHeartBeat() {
        Log.d(TAG, "into sendHeartBeat");
        sendBroadcast(new Intent("com.google.android.intent.action.MCS_HEARTBEAT"));
        Log.d(TAG, "First sendHeartBeat done");
        sendBroadcast(new Intent("com.google.android.intent.action.GTALK_HEARTBEAT"));
        Log.d(TAG, "Heartbeat sent done");
    }

    public void scheduleJob(String userid) {
        System.out.println("Inside scheduleJob function");
        System.out.println(userid);
        ComponentName componentName = new ComponentName(this, ExampleJobService.class);
        PersistableBundle bundle = new PersistableBundle();
        bundle.putString("userId", userid);
        JobInfo info = new JobInfo.Builder(1, componentName)
                .setPeriodic(15 * 60 * 1000)
                //.setOverrideDeadline(60 * 1000)
                .setExtras(bundle)
                .setPersisted(true)
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                .build();

        JobScheduler scheduler = (JobScheduler) getSystemService(JOB_SCHEDULER_SERVICE);
        int resultCode = scheduler.schedule(info);
        if (resultCode == JobScheduler.RESULT_SUCCESS) {
            Log.d(TAG, "Job Scheduled");
        } else {
            Log.d(TAG, "Job Scheduling failed");
        }
    }

    public void cancelJob() {
        JobScheduler scheduler = (JobScheduler) getSystemService(JOB_SCHEDULER_SERVICE);
        scheduler.cancel(1);
        Log.d(TAG, "Job cancelled");
    }

    private void startLocationService(String type) {
        Intent serviceIntent;
        if (type.equals("start")) {
            serviceIntent = new Intent(this, ExampleService.class);
            serviceIntent.putExtra("start", true);
            System.out.println("created intent");
        } else {
            serviceIntent = new Intent(this, ExampleService.class);
            serviceIntent.putExtra("start", false);
            System.out.println("created intent");
        }
        ContextCompat.startForegroundService(this, serviceIntent);
        System.out.println("forground service startd");

    }


    public void getLastLoc(String userid, String role) {
        String collectionName = role.equals("protector") ? "protector" : "girl_user";
        Log.i(TAG, "nikhar is nalayak for sure");
        System.out.println("nikhar first sout");
        mSettingsClient = LocationServices.getSettingsClient(this);
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
        Log.i(TAG, "fused location client done");
        System.out.println("fused location client done");
        //createLocationRequest();
        //buildLocationSettingsRequest();
        //mActivityRecognitionClient = new ActivityRecognitionClient(this);
        Toast.makeText(this, "nikhar is nalayak", Toast.LENGTH_LONG).show();
        Log.i(TAG, "hello afterr tttttttoooooassttttt");

        fusedLocationProviderClient.getLastLocation().addOnSuccessListener(this, new OnSuccessListener<Location>() {
            @Override
            public void onSuccess(Location location) {
                if (location != null) {
                    double lat = location.getLatitude();
                    double lng = location.getLongitude();
                    FirebaseFirestore db = FirebaseFirestore.getInstance();
                    Map<String, Object> loc = new HashMap<>();
                    GeoPoint geoPoint = new GeoPoint(lat, lng);
                    loc.put("last_location", geoPoint);
                    loc.put("last_updated", Calendar.getInstance().getTime());
                    //loc.put("jLatitide", lat);
                    //loc.put("jLongitude", lng);

                    db.collection(collectionName).document(userid).collection("location_info").document(userid).set(loc)
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    Log.d(TAG, "Location updated successfully");
                                }
                            }).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            Log.d(TAG, "Location not updated");
                        }
                    });
                }
            }
        });
    }

    /*@Override
    protected void onStart() {
        super.onStart();
        //PreferenceManager.getDefaultSharedPreferences(this).registerOnSharedPreferenceChangeListener();
        if(!checkPermissions()){
            requestPermissions();
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onStop() {
      //PreferenceManager.getDefaultSharedPreferences(this).unregisterOnSharedPreferenceChangeListener();
      super.onStop();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode){
            case REQUEST_CHECK_SETTINGS:
                switch (resultCode){
                    case Activity.RESULT_OK:
                        if(ActivityCompat.checkSelfPermission(this,
                                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                                ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
                                        != PackageManager.PERMISSION_GRANTED){
                            return;
                        }
                        //changeStatusAfterGetLastLocation("1", "Manual");
                        break;
                    case Activity.RESULT_CANCELED:
                        if(!checkPermissions()){
                            requestPermissions();
                        }
                        break;
                }
                break;
        }
    }

    private boolean checkPermissions() {
      int permissionState = ActivityCompat.checkSelfPermission(this,
              Manifest.permission.ACCESS_FINE_LOCATION);
      return permissionState == PackageManager.PERMISSION_GRANTED;
    }

    private void requestPermissions() {
        boolean shouldProvideRationale =
                ActivityCompat.shouldShowRequestPermissionRationale(this,
                        Manifest.permission.ACCESS_COARSE_LOCATION);

        if (shouldProvideRationale) {
            Log.i(TAG, "Displaying permission rationale to provide additional context.");


        } else {
            Log.i(TAG, "Requesting permission");
            startLocationPermissionRequest();
        }
    }

    private void startLocationPermissionRequest() {
      ActivityCompat.requestPermissions(MainActivity.this,
              new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
              REQUEST_PERMISSIONS_REQUEST_CODE);
    }

    private void buildLocationSettingsRequest() {
      LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
      builder.addLocationRequest(mLocationRequest);
      mLocationSettingsRequest = builder.build();
    }

    private void createLocationRequest() {
      */
    /*mLocationRequest = new LocationRequest();
      mLocationRequest.setInterval(Utils.UPDATE_INTERVAL);
      mLocationRequest.setFastestInterval(Utils.FASTEST_UPDATE_INTERVAL);
      mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
      mLocationRequest.setSmallestDisplacement(Utils.SMALLEST_DISPLACEMENT);
      mLocationRequest.setMaxWaitTime(Utils.MAX_WAIT_TIME);*//*

    }*/

    @Override

    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);


    }
}
