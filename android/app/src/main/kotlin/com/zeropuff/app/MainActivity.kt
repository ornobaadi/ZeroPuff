package com.zeropuff.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var launchChannel: MethodChannel? = null

    /** A route asked for before Flutter was ready to hear about it. */
    private var pendingRoute: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        pendingRoute = takeRoute(intent)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, HapticsChannel.NAME)
            .setMethodCallHandler(HapticsChannel(applicationContext))

        launchChannel = MethodChannel(messenger, LaunchRoute.CHANNEL).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method == "takeInitialRoute") {
                    result.success(pendingRoute)
                    pendingRoute = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = takeRoute(intent) ?: return
        launchChannel?.invokeMethod("openRoute", route) ?: run { pendingRoute = route }
    }

    /** Reads the route once, so rotating the screen does not reopen it. */
    private fun takeRoute(intent: Intent?): String? {
        val route = intent?.getStringExtra(LaunchRoute.EXTRA) ?: return null
        intent.removeExtra(LaunchRoute.EXTRA)
        return route
    }
}
