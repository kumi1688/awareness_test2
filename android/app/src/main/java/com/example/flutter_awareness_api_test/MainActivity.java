package com.example.flutter_awareness_api_test;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.awareness.Awareness;
import com.google.android.gms.awareness.snapshot.DetectedActivityResponse;
import com.google.android.gms.awareness.snapshot.HeadphoneStateResponse;
import com.google.android.gms.awareness.snapshot.LocationResponse;
import com.google.android.gms.awareness.state.HeadphoneState;
import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.example.flutter_awareness_api_test.classes.MyDetectiveActivity;
import com.google.android.gms.tasks.Task;
import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.model.PlaceLikelihood;
import com.google.android.libraries.places.api.net.FindCurrentPlaceRequest;
import com.google.android.libraries.places.api.net.FindCurrentPlaceResponse;
import com.google.android.libraries.places.api.net.PlacesClient;

public class MainActivity extends FlutterActivity {
    private String _headphoneState = "헤드폰 상태";
    private String _userState = "";
    private String _userLocation = "";
    private String _userPlace = "";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), "com.example.flutter_awareness_api_test");
        channel.setMethodCallHandler(handler);
    }

    private MethodChannel.MethodCallHandler handler = (methodCall, result) -> {
        if (methodCall.method.equals("getPlatformVersion")) {
            result.success("Android Version: " + Build.VERSION.RELEASE);

        } else if (methodCall.method.equals("getHeadphoneState")) {
            getHeadphoneState(result);
        } else if (methodCall.method.equals("getUserState")) {
            getUserState(result);
        } else if (methodCall.method.equals("getUserLocation")) {
            getUserLocation(result);
        } else if (methodCall.method.equals("getUserPlace")){
            getUserPlace(result);
        }

        else {
            result.notImplemented();
        }
    };

    private void getHeadphoneState(MethodChannel.Result result) {
        Awareness.getSnapshotClient(this).getHeadphoneState()
                .addOnSuccessListener(new OnSuccessListener<HeadphoneStateResponse>() {
                    @Override
                    public void onSuccess(HeadphoneStateResponse headphoneStateResponse) {
                        int state = headphoneStateResponse.getHeadphoneState().getState();

                        if (state == HeadphoneState.PLUGGED_IN) {
                            _headphoneState = "헤드폰 연결 됨";
                        } else if (state == HeadphoneState.UNPLUGGED) {
                            _headphoneState = "헤드폰 연결 되지 않음";
                        }

                        result.success(_headphoneState);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        e.printStackTrace();
                        _headphoneState = "헤드폰 상태 가져올 수 없음";
                        result.success(_headphoneState);
                    }
                });
    }

    private void getUserState(MethodChannel.Result result) {
        Awareness.getSnapshotClient(this).getDetectedActivity()
                .addOnSuccessListener(new OnSuccessListener<DetectedActivityResponse>() {
                    @Override
                    public void onSuccess(DetectedActivityResponse dar) {
                        ActivityRecognitionResult arr = dar.getActivityRecognitionResult();
                        DetectedActivity probableActivity = arr.getMostProbableActivity();

                        int confidence = probableActivity.getConfidence();
                        int type = probableActivity.getType();

                        MyDetectiveActivity myDetectiveActivity = new MyDetectiveActivity(type, confidence);
                        _userState = "확률 : " + myDetectiveActivity.getConfidence() + "%" + ", "
                                + "활동 : " + myDetectiveActivity.getType();
                        result.success(_userState);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        e.printStackTrace();
//                        _userState = "사용자 상태 가져올 수 없음";
                        result.success(_userState);
                    }
                });
    }

    private void getUserLocation(MethodChannel.Result result) {
        if(!checkPermission()) {
            _userLocation = "위치 권한 거부됨";
            result.success(_userLocation);
            return;
        }

        Awareness.getSnapshotClient(this).getLocation()
                .addOnSuccessListener(new OnSuccessListener<LocationResponse>() {
                    @Override
                    public void onSuccess(LocationResponse locationResponse) {
                        Location loc = locationResponse.getLocation();
                        _userLocation = "정확도 : " + loc.getAccuracy() + ", "
                                + "위도 : " + loc.getLatitude() + ", "
                                + "경도" + loc.getLongitude() + ", "
                                + "고도" + loc.getAltitude();
                        result.success(_userLocation);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        e.printStackTrace();
                        _userLocation = "사용자의 위치를 가져올 수 없음";
                        result.success(_userLocation);
                    }
                });
    }

    private void getUserPlace(MethodChannel.Result result){
        if(!checkPermission()){
            return;
        }

        // Initialize the SDK
        Places.initialize(getApplicationContext(), "AIzaSyBD0A7bTA5mEl5G1odnxfz-TzJFsaD7wr4");

        // Create a new Places client instance
        PlacesClient placesClient = Places.createClient(this);

        List<Place.Field> placeFields = Collections.singletonList(Place.Field.NAME);

        // Use the builder to create a FindCurrentPlaceRequest.
        FindCurrentPlaceRequest request =
                FindCurrentPlaceRequest.newInstance(placeFields);

        Task<FindCurrentPlaceResponse> placeResponse = placesClient.findCurrentPlace(request);
        placeResponse
                .addOnSuccessListener(new OnSuccessListener<FindCurrentPlaceResponse>() {
                    @Override
                    public void onSuccess(FindCurrentPlaceResponse findCurrentPlaceResponse) {

                        List<String> places = new ArrayList<String>();
                        for (PlaceLikelihood placeLikelihood : findCurrentPlaceResponse.getPlaceLikelihoods()) {
                             String userPlace = "";
                             userPlace += placeLikelihood.getPlace().getName() + ", ";
                             userPlace += placeLikelihood.getLikelihood() * 1000 + "%";
                             places.add(userPlace);
                            System.out.println(userPlace);
                        }
                        result.success(places);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        e.printStackTrace();
                        _userPlace = "사용자의 주소 파악 불가능";
                        result.success(_userPlace);
                    }
                });
    }

    private boolean checkPermission(){

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return false;
        }
        return true;
    }

    private List<MyDetectiveActivity> convertToMap(List<DetectedActivity> detectedActivities){
        List<MyDetectiveActivity> result = new ArrayList<MyDetectiveActivity>();

        for(DetectedActivity detectedActivity: detectedActivities){
            int type = detectedActivity.getType();
            int confidence = detectedActivity.getConfidence();
            MyDetectiveActivity myDetectiveActivity = new MyDetectiveActivity(type, confidence);
            result.add(myDetectiveActivity);
        }
        return result;
    }
}

