import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cityName: "Loading...", temperature: "--°", condition: "--")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Read from App Group UserDefaults populated by home_widget
        let userDefaults = UserDefaults(suiteName: "group.com.example.weather")
        let cityName = userDefaults?.string(forKey: "cityName") ?? "Loading..."
        let temperature = userDefaults?.string(forKey: "temperature") ?? "--°"
        let condition = userDefaults?.string(forKey: "condition") ?? "--"
        
        let entry = SimpleEntry(date: Date(), cityName: cityName, temperature: temperature, condition: condition)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: String
    let condition: String
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.cityName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                // In iOS 17+, you can use interactive buttons in widgets.
                // For simplicity, we just display the refresh icon.
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
            }
            Spacer()
            Text(entry.temperature)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text(entry.condition)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(red: 30/255, green: 41/255, blue: 59/255))
    }
}

@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather Widget")
        .description("Current weather conditions for your city.")
        .supportedFamilies([.systemSmall])
    }
}
