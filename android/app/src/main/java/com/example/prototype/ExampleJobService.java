package com.example.prototype;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.location.Location;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.GeoPoint;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

public class ExampleJobService extends JobService {
    private static final String TAG = "ExampleJobService";
    private boolean jobCancelled = false;
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;
    //private LocationRequest mLocationRequest;
    //private LocationSettingsRequest mLocationSettingsRequest;


    @Override
    public boolean onStartJob(JobParameters params) {
        Log.d(TAG, "Job started");
        doLocationUpdate(params);

        return true;
    }

    private void doLocationUpdate(JobParameters params) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                if(jobCancelled)
                    return;
                getLastLoc(params, params.getExtras().getString("userId"));
            }
        }).start();
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        Log.d(TAG, "Job Cancelled before completion");
        jobCancelled = true;
        return true;

    }

    public void getLastLoc(JobParameters parameters, String userid) {
        Log.i(TAG, "nikhar is nalayak for sure");
        System.out.println("nikhar first sout");
        SettingsClient mSettingsClient = LocationServices.getSettingsClient(this);
        FusedLocationProviderClient fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
        Log.i(TAG, "fused location client done");
        System.out.println("fused location client done");
        //createLocationRequest();
        //buildLocationSettingsRequest();
        //mActivityRecognitionClient = new ActivityRecognitionClient(this);
        //Toast.makeText(this, "nikhar is nalayak", Toast.LENGTH_LONG).show();
        Log.i(TAG, "hello afterr tttttttoooooassttttt");
        if (jobCancelled)
            return;
        fusedLocationProviderClient.getLastLocation().addOnSuccessListener(
                new OnSuccessListener<Location>() {
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

                            db.collection("protector").document(userid).collection("location_info").document(userid).set(loc)
                                    .addOnSuccessListener(new OnSuccessListener<Void>() {
                                        @Override
                                        public void onSuccess(Void aVoid) {
                                            Log.d(TAG, "Location updated successfully");
                                            jobFinished(parameters, false);
                                        }
                                    }).addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    Log.d(TAG, "Location not updated");
                                    jobFinished(parameters, true);
                                }
                            });
                        }
                        else{
                            jobFinished(parameters, false);
                        }
                    }

                }
        );
    }
}
