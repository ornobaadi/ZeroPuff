package com.zeropuff.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import java.text.NumberFormat
import kotlin.math.floor

/**
 * Home-screen widget: smoke-free days, money kept, and a button straight into
 * the craving rescue.
 *
 * The app stores when the smoke-free period began and the old daily spend, and
 * the numbers are worked out here, so they stay right on days the app is not
 * opened.
 */
class ZeroPuffWidgetProvider : AppWidgetProvider() {
    companion object {
        // Where the home_widget plugin keeps what the app saves for widgets.
        private const val PREFERENCES = "HomeWidgetPreferences"
        private const val KEY_SINCE = "smoke_free_since_ms"
        private const val KEY_DAILY_SPEND = "daily_spend"
        private const val KEY_CURRENCY = "currency_symbol"
        private const val DAY_MS = 24 * 60 * 60 * 1000.0
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val data = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val since = data.getString(KEY_SINCE, null)?.toLongOrNull()
        val dailySpend = data.getString(KEY_DAILY_SPEND, null)?.toDoubleOrNull() ?: 0.0
        val currency = data.getString(KEY_CURRENCY, null) ?: ""

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.zeropuff_widget)

            if (since == null) {
                views.setTextViewText(R.id.widget_days, "0")
                views.setTextViewText(
                    R.id.widget_days_label,
                    context.getString(R.string.widget_setup_hint),
                )
                views.setTextViewText(R.id.widget_money, "")
            } else {
                val elapsedDays = ((System.currentTimeMillis() - since) / DAY_MS).coerceAtLeast(0.0)
                val days = floor(elapsedDays).toInt()
                val money = floor(elapsedDays * dailySpend).toLong()
                views.setTextViewText(R.id.widget_days, days.toString())
                views.setTextViewText(
                    R.id.widget_days_label,
                    context.getString(
                        if (days == 1) R.string.widget_day_label else R.string.widget_days_label,
                    ),
                )
                views.setTextViewText(
                    R.id.widget_money,
                    if (money > 0) "$currency${NumberFormat.getIntegerInstance().format(money)}" else "",
                )
            }

            views.setOnClickPendingIntent(
                R.id.widget_craving,
                LaunchRoute.pendingIntent(context, LaunchRoute.RESCUE, 1),
            )
            views.setOnClickPendingIntent(
                R.id.widget_stats,
                LaunchRoute.pendingIntent(context, "/home", 2),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
