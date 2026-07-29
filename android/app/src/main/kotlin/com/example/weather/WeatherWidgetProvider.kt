package com.example.weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import android.net.Uri

class WeatherWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

            // Select layout dynamically based on size constraints
            // Small is standard 2x2, Medium is 4x2, Large is 4x4
            val layoutId = when {
                minHeight >= 250 -> R.layout.widget_large
                minWidth >= 250 -> R.layout.widget_medium
                else -> R.layout.widget_small
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                val cityName = widgetData.getString("cityName", "Select City")
                val temperature = widgetData.getString("temperature", "--°")
                val condition = widgetData.getString("condition", "--")
                val tempMin = widgetData.getString("tempMin", "--°")
                val tempMax = widgetData.getString("tempMax", "--°")
                val lastUpdated = widgetData.getString("lastUpdated", "--:--")

                setTextViewText(R.id.widget_city, cityName)
                setTextViewText(R.id.widget_temp, temperature)
                setTextViewText(R.id.widget_condition, condition)
                
                // Fields present in medium/large layouts
                try {
                    setTextViewText(R.id.widget_high_low, "H: $tempMax  L: $tempMin")
                    setTextViewText(R.id.widget_last_updated, "Updated: $lastUpdated")
                } catch (e: Exception) {}

                // Icon Resolution mapping
                val iconResId = when {
                    condition.contains("sunny", ignoreCase = true) || condition.contains("clear", ignoreCase = true) -> R.drawable.ic_sunny
                    condition.contains("cloud", ignoreCase = true) -> R.drawable.ic_cloudy
                    condition.contains("rain", ignoreCase = true) || condition.contains("drizzle", ignoreCase = true) -> R.drawable.ic_rainy
                    condition.contains("thunder", ignoreCase = true) || condition.contains("storm", ignoreCase = true) -> R.drawable.ic_storm
                    condition.contains("snow", ignoreCase = true) -> R.drawable.ic_snowy
                    else -> R.drawable.ic_cloudy
                }
                setImageViewResource(R.id.widget_icon, iconResId)

                // Refresh Button Action -> Wakes up background sync dispatcher
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("weatherWidget://refresh")
                )
                setOnClickPendingIntent(R.id.widget_refresh, backgroundIntent)

                // Tap Widget Content -> Open MainActivity
                val mainIntent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, mainIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
