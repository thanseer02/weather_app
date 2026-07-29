package com.example.weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class WeatherWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weather_widget_layout).apply {

                val cityName = widgetData.getString("cityName", "Unknown")
                val temperature = widgetData.getString("temperature", "--°")
                val condition = widgetData.getString("condition", "--")

                setTextViewText(R.id.widget_city, cityName)
                setTextViewText(R.id.widget_temp, temperature)
                setTextViewText(R.id.widget_condition, condition)

                // Refresh Button Action -> Wake up flutter background task
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("weatherWidget://refresh")
                )
                setOnClickPendingIntent(R.id.widget_refresh, backgroundIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
