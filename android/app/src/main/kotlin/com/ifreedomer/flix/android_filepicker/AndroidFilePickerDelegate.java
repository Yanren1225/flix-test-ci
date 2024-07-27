package com.ifreedomer.flix.android_filepicker;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.Parcelable;
import android.util.Log;

import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;

import com.hippo.unifile.UniFile;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class AndroidFilePickerDelegate implements PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

    private static final String TAG = "FilePickerDelegate";
    private static final int REQUEST_CODE = (FilePickerPlugin.class.hashCode() + 43) & 0x0000ffff;

    private final Activity activity;
    private final PermissionManager permissionManager;
    private MethodChannel.Result pendingResult;
    private boolean isMultipleSelection = false;
    private boolean loadDataToMemory = false;
    private String type;
    private int compressionQuality=20;
    private String[] allowedExtensions;
    private EventChannel.EventSink eventSink;

    public AndroidFilePickerDelegate(final Activity activity) {
        this(
                activity,
                null,
                new PermissionManager() {
                    @Override
                    public boolean isPermissionGranted(final String permissionName) {
                        return ActivityCompat.checkSelfPermission(activity, permissionName)
                                == PackageManager.PERMISSION_GRANTED;
                    }

                    @Override
                    public void askForPermission(final String permissionName, final int requestCode) {
                        ActivityCompat.requestPermissions(activity, new String[]{permissionName}, requestCode);
                    }

                }
        );
    }

    public void setEventHandler(final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @VisibleForTesting
    AndroidFilePickerDelegate(final Activity activity, final MethodChannel.Result result, final PermissionManager permissionManager) {
        this.activity = activity;
        this.pendingResult = result;
        this.permissionManager = permissionManager;
    }


    @Override
    public boolean onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        if (type == null) {
            return false;
        }

        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            this.dispatchEventStatus(true);
            if (data == null) {
                finishWithError("unknown_activity", "Unknown activity error, please fill an issue.");
                return true;
            }

            final ArrayList<String> uris = new ArrayList<>();

            if (data.getClipData() != null) {
                final int count = data.getClipData().getItemCount();
                int currentItem = 0;
                while (currentItem < count) {
                    Uri currentUri = data.getClipData().getItemAt(currentItem).getUri();
                    uris.add(currentUri.toString());
                    currentItem++;
                }
                finishWithSuccess(uris);
            } else if (data.getData() != null) {
                Uri uri = data.getData();
                uris.add(uri.toString());
                finishWithSuccess(uris);
            } else if (data.getExtras() != null){
                Bundle bundle = data.getExtras();
                if (bundle.keySet().contains("selectedItems")) {
                    ArrayList<Parcelable> fileUris = getSelectedItems(bundle);
                    if (fileUris != null) {
                        for (Parcelable fileUri : fileUris) {
                            if (fileUri instanceof Uri) {
                                Uri currentUri = (Uri) fileUri;
                                uris.add(currentUri.toString());
                            }
                        }
                    }
                }
                finishWithSuccess(uris);
            } else {
                finishWithError("unknown_activity", "Unknown activity error, please fill an issue.");
            }
            return true;

        } else if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
            Log.i(TAG, "User cancelled the picker request");
            finishWithSuccess(null);
            return true;
        } else if (requestCode == REQUEST_CODE) {
            finishWithError("unknown_activity", "Unknown activity error, please fill an issue.");
        }
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(final int requestCode, final String[] permissions, final int[] grantResults) {

        if (REQUEST_CODE != requestCode) {
            return false;
        }

        final boolean permissionGranted =
                grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;

        if (permissionGranted) {
            this.startFileExplorer();
        } else {
            finishWithError("read_external_storage_denied", "User did not allow reading external storage");
        }

        return true;
    }

    private boolean setPendingMethodCallAndResult(final MethodChannel.Result result) {
        if (this.pendingResult != null) {
            return false;
        }
        this.pendingResult = result;
        return true;
    }

    private static void finishWithAlreadyActiveError(final MethodChannel.Result result) {
        result.error("already_active", "File picker is already active", null);
    }

    @SuppressWarnings("deprecation")
    private ArrayList<Parcelable> getSelectedItems(Bundle bundle){
        if(Build.VERSION.SDK_INT >= 33){
            return bundle.getParcelableArrayList("selectedItems", Parcelable.class);
        }

        return bundle.getParcelableArrayList("selectedItems");
    }

    private void startFileExplorer() {
        final Intent intent;

        // Temporary fix, remove this null-check after Flutter Engine 1.14 has landed on stable
        if (type == null) {
            return;
        }

        if (type.equals("dir")) {
            intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        } else {
            if (type.equals("image/*")) {
                intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            } else {
                intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
            }
            final Uri uri = Uri.parse(Environment.getExternalStorageDirectory().getPath() + File.separator);
            Log.d(TAG, "Selected type " + type);
            intent.setDataAndType(uri, this.type);
            intent.setType(this.type);
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, this.isMultipleSelection);
            intent.putExtra("multi-pick", this.isMultipleSelection);

            if (type.contains(",")) {
                allowedExtensions = type.split(",");
            }

            if (allowedExtensions != null) {
                intent.putExtra(Intent.EXTRA_MIME_TYPES, allowedExtensions);
            }
        }

        if (intent.resolveActivity(this.activity.getPackageManager()) != null) {
            this.activity.startActivityForResult(Intent.createChooser(intent, null), REQUEST_CODE);
        } else {
            Log.e(TAG, "Can't find a valid activity to handle the request. Make sure you've a file explorer installed.");
            finishWithError("invalid_format_type", "Can't handle the provided file type.");
        }
    }

    @SuppressWarnings("deprecation")
    public void startFileExplorer(final String type, final boolean isMultipleSelection, final boolean withData, final String[] allowedExtensions, final int compressionQuality, final MethodChannel.Result result) {

        if (!this.setPendingMethodCallAndResult(result)) {
            finishWithAlreadyActiveError(result);
            return;
        }
        this.type = type;
        this.isMultipleSelection = isMultipleSelection;
        this.loadDataToMemory = withData;
        this.allowedExtensions = allowedExtensions;
        this.compressionQuality=compressionQuality;
        // `READ_EXTERNAL_STORAGE` permission is not needed since SDK 33 (Android 13 or higher).
        // `READ_EXTERNAL_STORAGE` & `WRITE_EXTERNAL_STORAGE` are no longer meant to be used, but classified into granular types.
        // Reference: https://developer.android.com/about/versions/13/behavior-changes-13
        if (Build.VERSION.SDK_INT < 33) {
            if (!this.permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)) {
                this.permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE, REQUEST_CODE);
                return;
            }
        }
        this.startFileExplorer();
    }

    @SuppressWarnings("unchecked")
    private void finishWithSuccess(List<String> uriList) {
        this.dispatchEventStatus(false);
        ArrayList<Map<String, Object>> fileList = new ArrayList<>();
        if (uriList == null) {
            this.pendingResult.success(fileList);
            this.clearPendingResult();
            return;
        }
        // Temporary fix, remove this null-check after Flutter Engine 1.14 has landed on stable
        if (this.pendingResult != null) {


            for (String s : uriList) {
                UniFile uniFile = UniFile.fromUri(activity, Uri.parse(s));
                if (uniFile == null) {
                    continue;
                }
                AndroidFileInfo.Builder builder = new AndroidFileInfo.Builder();
                builder.withPath(uniFile.getFilePath());
                builder.withUri(s);
                builder.withName(uniFile.getName());
                builder.withSize(uniFile.length());
                fileList.add(builder.build().toMap());
            }

            this.pendingResult.success(fileList);
            this.clearPendingResult();
        }
    }

    private void finishWithError(final String errorCode, final String errorMessage) {
        if (this.pendingResult == null) {
            return;
        }

        this.dispatchEventStatus(false);
        this.pendingResult.error(errorCode, errorMessage, null);
        this.clearPendingResult();
    }

    private void dispatchEventStatus(final boolean status) {

        if(eventSink == null || type.equals("dir")) {
            return;
        }

        new Handler(Looper.getMainLooper()) {
            @Override
            public void handleMessage(final Message message) {
                eventSink.success(status);
            }
        }.obtainMessage().sendToTarget();
    }


    private void clearPendingResult() {
        this.pendingResult = null;
    }

    interface PermissionManager {
        boolean isPermissionGranted(String permissionName);

        void askForPermission(String permissionName, int requestCode);
    }

}
