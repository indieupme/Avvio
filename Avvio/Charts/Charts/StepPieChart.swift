
import SwiftUI
import Charts

struct StepPieChart: View {

    @State private var rawSelectedChartValue: Double? = 0
    @State private var lastSelectedValue: Double = 0
    @State private var selectedDay: Date?

    var selectedWeekday: DateValueChartData? {
        var total = 0.0

        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }

    var chartData: [DateValueChartData]

    var body: some View {
        ChartContainer(chartType: .stepWeekdayPie) {
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(angle: .value("Average Steps", weekday.value),
                               innerRadius: .ratio(0.618),
                               outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                               angularInset: 1)
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                    .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                    .accessibilityLabel(weekday.date.weekdayTitle)
                    .accessibilityValue("\(Int(weekday.value)) step")
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue)
            .onChange(of: rawSelectedChartValue) { oldValue, newValue in
                withAnimation(.easeInOut) {
                    guard let newValue else {
                        lastSelectedValue = oldValue ?? 0
                        return
                    }

                    lastSelectedValue = newValue
                }
            }
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .animation(.none)

                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityHidden(true)
                        }
                    }
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.pie", title: "No Data", description: "There is no step count data from the Health App.")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: MockData.steps))
}
