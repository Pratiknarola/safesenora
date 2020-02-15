package com.example.prototype;

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



  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
              if(call.method.equals("getLastLocation")){
                  getLastLoc();
              }
              else if(call.method.equals("startLocationService")){
                  System.out.println("Got in start location");
                  startLocationService();
              }
            });

  }

    private void startLocationService() {
        Intent serviceIntent = new Intent(this, ExampleService.class);
        System.out.println("created intent");
        ContextCompat.startForegroundService(this, serviceIntent);
        System.out.println("forground service startd");

    }

    public void getLastLoc(){
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
      Log.i(TAG,"hello afterr tttttttoooooassttttt");

      fusedLocationProviderClient.getLastLocation().addOnSuccessListener(this, new OnSuccessListener<Location>() {
          @Override
          public void onSuccess(Location location) {
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
