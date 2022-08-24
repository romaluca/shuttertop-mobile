package com.shuttertop.android;

import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.google.firebase.messaging.RemoteMessage;

public class MainActivity extends FlutterActivity {
  private String sharedImage;
  private RemoteMessage notify;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    checkSharedImage(getIntent());
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    switch (intent.getAction()) {
      case Intent.ACTION_SEND:
        checkSharedImage(intent);
        break;
      case "SELECT_NOTIFICATION":
        checkNotification(intent);
        break;
    }


  }


  void checkNotification(Intent intent) {
    String action = intent.getAction();
    String type = intent.getType();
    Log.i("MAIN_ACTIVITY", "new intent: type: " + type + "action: " + action);

    notify = intent.getParcelableExtra("NOTIFICATION");

    MethodChannel channel = new MethodChannel(getFlutterView(), "app.channel.shared.data");
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.contentEquals("getNotification") && notify != null) {
          result.success(notify.getData());
          notify = null;
        }
      }
    });
  }

  void checkSharedImage(Intent intent) {
    String action = intent.getAction();
    String type = intent.getType();
    Log.i("MAIN_ACTIVITY", "new intent: type: " + type + "action: " + action);
    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if ("image/jpeg".equals(type)) {
        handleSendImage(intent);
      }
    }
    MethodChannel channel = new MethodChannel(getFlutterView(), "app.channel.shared.data");
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.contentEquals("getSharedImage")) {
          result.success(sharedImage);
          sharedImage = null;
        }
      }
    });
  }

  void handleSendImage(Intent intent) {
    Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
    sharedImage = new FileUtils().getPathFromUri(this, uri);
    Log.i("MAIN_ACTIVITY", "sendImage path: " + sharedImage);
  }


}
