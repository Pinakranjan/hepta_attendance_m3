package com.example.hepta_attendance

import android.Manifest
import android.app.AlertDialog
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.telephony.TelephonyManager

import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.Toast

import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private var SERIAL_NO_CHANNEL = "heptaattendance/serialno"
    private lateinit var channel: MethodChannel

    private val requestState = 100
    private var checkedPermission = PackageManager.PERMISSION_DENIED
    lateinit var manager: TelephonyManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERIAL_NO_CHANNEL)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "getSerialNo") {
                val arguments = call.arguments as Map<String, String>
                val message = arguments["message"]
                val serialno = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)

//                manager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
//                serialno = manager.imei;

//                if (checkedPermission != PackageManager.PERMISSION_DENIED) {
//                    serialno = "${Build.getSerial().replace(" ","-")}-${Build.BRAND.replace(" ","-")}-${Build.MODEL.replace(" ","-")}"
//                    serialno = "${Build.getSerial().replace(" ","-")}"
//                }

                result.success(serialno)
            }
        }
    }

//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
////        setContentView(R.layout.activity_main)
//        title = "KotlinApp"
//        checkedPermission = ContextCompat.checkSelfPermission(this,
//                Manifest.permission.READ_PHONE_STATE);
//        if (Build.VERSION.SDK_INT >= 23 && checkedPermission !=
//                PackageManager.PERMISSION_GRANTED) {
//            requestPermission();
//        } else
//            checkedPermission = PackageManager.PERMISSION_GRANTED;
//    }
//    private fun requestPermission() {
//        Toast.makeText(this, "Requesting permission", Toast.LENGTH_SHORT).show()
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            this.requestPermissions(arrayOf(Manifest.permission.READ_PHONE_STATE), requestState)
//        }
//    }
//    fun showDeviceInfo() {
//        manager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
//        val dBuilder: AlertDialog.Builder = AlertDialog.Builder(this)
//        val stringBuilder = StringBuilder()
//        if (checkedPermission != PackageManager.PERMISSION_DENIED) {
//            dBuilder.setTitle("Device Info")
//            stringBuilder.append("""
//            SERIAL : ${Build.getSerial()}
//            """.trimIndent())
//        } else {
//            dBuilder.setTitle("Permission denied")
//            stringBuilder.append("Can't access device info !")
//        }
//        dBuilder.setMessage(stringBuilder)
//        dBuilder.show()
//    }
//    override fun onRequestPermissionsResult(requestCode: Int, vararg permissions: String?, grantResults: IntArray) {
//        when (requestCode) {
//            requestState -> if (grantResults.isNotEmpty() && grantResults[0] == PackageManager
//                            .PERMISSION_GRANTED) {
//                checkedPermission = PackageManager.PERMISSION_GRANTED
//            }
//        }
//    }
}
