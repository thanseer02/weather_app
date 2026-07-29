import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            cityName: "Loading...",
            temperature: "--°",
            condition: "--",
            iconCode: "01d",
            tempMin: "--°",
            tempMax: "--°",
            lastUpdated: "--:--",
            sparklineData: [70, 71, 72, 70, 68]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.weather")
        let cityName = userDefaults?.string(forKey: "cityName") ?? "San Francisco"
        let temperature = userDefaults?.string(forKey: "temperature") ?? "72°"
        let condition = userDefaults?.string(forKey: "condition") ?? "Clear"
        let iconCode = userDefaults?.string(forKey: "iconCode") ?? "01d"
        let tempMin = userDefaults?.string(forKey: "tempMin") ?? "65°"
        let tempMax = userDefaults?.string(forKey: "tempMax") ?? "78°"
        let lastUpdated = userDefaults?.string(forKey: "lastUpdated") ?? "12:00"
        
        let entry = SimpleEntry(
            date: Date(),
            cityName: cityName,
            temperature: temperature,
            condition: condition,
            iconCode: iconCode,
            tempMin: tempMin,
            tempMax: tempMax,
            lastUpdated: lastUpdated,
            sparklineData: [68, 70, 72, 71, 69]
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: String
    let condition: String
    let iconCode: String
    let tempMin: String
    let tempMax: String
    let lastUpdated: String
    let sparklineData: [Double]
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            case .accessoryCircular:
                AccessoryCircularView(entry: entry)
            case .accessoryRectangular:
                AccessoryRectangularView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
            }
        }
        .widgetURL(URL(string: "skyline://open-widget")) // Open app on widget click
    }
}

// MARK: - Sparkline Graph View

struct SparklineGraph: View {
    let dataPoints: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard dataPoints.count > 1 else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                let minVal = dataPoints.min() ?? 0
                let maxVal = dataPoints.max() ?? 100
                let delta = maxVal - minVal == 0 ? 1 : maxVal - minVal
                
                let stepX = width / CGFloat(dataPoints.count - 1)
                
                let firstY = height - CGFloat((dataPoints[0] - minVal) / delta) * height
                path.moveTo(0, firstY)
                
                for index in 1..<dataPoints.count {
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat((dataPoints[index] - minVal) / delta) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.white, lineWidth: 2)
            .shadow(color: Color.white.opacity(0.4), radius: 2, x: 0, y: 1)
        }
        .frame(height: 30)
    }
}

// MARK: - Subviews

struct WeatherIcon: View {
    let condition: String
    let size: CGFloat

    var body: some View {
        let systemName = getSfSymbol(for: condition)
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .symbolRenderingMode(.multicolor)
    }

    private func getSfSymbol(for condition: String) -> String {
        let cond = condition.lowercased()
        if cond.contains("sunny") || cond.contains("clear") {
            return "sun.max.fill"
        } else if cond.contains("cloud") {
            return "cloud.fill"
        } else if cond.contains("rain") || cond.contains("drizzle") {
            return "cloud.rain.fill"
        } else if cond.contains("thunder") || cond.contains("storm") {
            return "cloud.bolt.rain.fill"
        } else if cond.contains("snow") {
            return "snowflake"
        } else {
            return "cloud.sun.fill"
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.cityName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Spacer()
                WeatherIcon(condition: entry.condition, size: 22)
            }
            Spacer()
            Text(entry.temperature)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(entry.condition)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.black.opacity(0.15)
                .background(.ultraThinMaterial) // macOS Glass effect
        }
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.cityName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text("H: \(entry.tempMax)  L: \(entry.tempMin)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                
                // Embedded Sparkline Temp Graph
                SparklineGraph(dataPoints: entry.sparklineData)
                    .padding(.top, 4)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.temperature)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    WeatherIcon(condition: entry.condition, size: 32)
                }
                Text(entry.condition)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Updated \(entry.lastUpdated)")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.black.opacity(0.15)
                .background(.ultraThinMaterial) // macOS Glass effect
        }
    }
}

struct LargeWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.cityName)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Last Updated: \(entry.lastUpdated)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                Spacer()
                WeatherIcon(condition: entry.condition, size: 44)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(entry.temperature)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.condition)
                        .font(.headline)
                    Text("H: \(entry.tempMax)  L: \(entry.tempMin)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Sparkline Temp Graph View
            VStack(alignment: .leading, spacing: 4) {
                Text("Temperature Trend")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                SparklineGraph(dataPoints: entry.sparklineData)
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color.secondary.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Forecast")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForecastItem(time: "Now", temp: entry.temperature, condition: entry.condition)
                    Spacer()
                    ForecastItem(time: "+3h", temp: entry.temperature, condition: entry.condition)
                    Spacer()
                    ForecastItem(time: "+6h", temp: entry.temperature, condition: entry.condition)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.black.opacity(0.15)
                .background(.ultraThinMaterial) // macOS Glass effect
        }
    }
}

struct ForecastItem: View {
    let time: String
    let temp: String
    let condition: String

    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            WeatherIcon(condition: condition, size: 20)
            Text(temp)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct AccessoryCircularView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 14))
            Text(entry.temperature)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct AccessoryRectangularView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.cityName)
                .font(.system(size: 10, weight: .bold))
            HStack {
                Image(systemName: "sun.max.fill")
                Text(entry.temperature)
                    .font(.system(size: 14, weight: .black))
            }
            Text(entry.condition)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Widget Config

@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Skyline Weather")
        .description("View current weather summaries instantly.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}
