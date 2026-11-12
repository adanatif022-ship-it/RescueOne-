package com.smartemergency360.smart_emergency_360

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Adds one native feature: picking a trusted contact from the phone.
 * ACTION_PICK opens the system contact picker, which grants access to the
 * single contact the user taps - so no READ_CONTACTS permission is needed.
 */
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "pickContact") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (pendingResult != null) {
                    result.error("busy", "The contact picker is already open", null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                val intent = Intent(
                    Intent.ACTION_PICK,
                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                )
                try {
                    startActivityForResult(intent, PICK_CONTACT_REQUEST)
                } catch (e: ActivityNotFoundException) {
                    pendingResult = null
                    result.success(null)
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_CONTACT_REQUEST) return
        val result = pendingResult ?: return
        pendingResult = null

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            val projection = arrayOf(
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER,
            )
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    result.success(
                        mapOf(
                            "name" to (cursor.getString(0) ?: ""),
                            "phone" to (cursor.getString(1) ?: ""),
                        ),
                    )
                    return
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.success(null)
        }
    }

    companion object {
        private const val CHANNEL = "rescue_one/contacts"
        private const val PICK_CONTACT_REQUEST = 4711
    }
}
