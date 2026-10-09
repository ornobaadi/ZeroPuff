package com.zeropuff.app

import android.app.PendingIntent
import android.content.Context
import android.content.Intent

/** Opening the app at a particular screen from outside it (widget, tile). */
object LaunchRoute {
    const val CHANNEL = "zeropuff/launch"
    const val EXTRA = "zeropuff_route"
    const val RESCUE = "/rescue"

    private const val ACTION = "com.zeropuff.app.OPEN_ROUTE"

    // Not the launcher intent: Android would bring the running app forward
    // without delivering it, and the route would be lost.
    fun intent(context: Context, route: String): Intent =
        Intent(context, MainActivity::class.java)
            .setAction(ACTION)
            .addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            .putExtra(EXTRA, route)

    fun pendingIntent(context: Context, route: String, requestCode: Int): PendingIntent =
        PendingIntent.getActivity(
            context,
            requestCode,
            intent(context, route),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
}
