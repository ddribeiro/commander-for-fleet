import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: "Enrolled Hosts", value: "\(dataController.hosts.count)", icon: "laptopcomputer", color: .blue)
                    StatCard(title: "Users", value: "\(dataController.users.count)", icon: "person.2", color: .green)
                    StatCard(title: "Software", value: "\(dataController.software.count)", icon: "square.stack.3d.up", color: .orange)
                    StatCard(title: "Policies", value: "\(dataController.policies.count)", icon: "checkmark.seal", color: .purple)
                }
                
                // Platform Breakdown Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hosts by Platform")
                        .font(.headline)
                    
                    Chart(platformData) { item in
                        BarMark(
                            x: .value("Platform", item.platform),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(by: .value("Platform", item.platform))
                    }
                    .frame(height: 300)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Home")
    }
    
    private var platformData: [PlatformCount] {
        let counts = Dictionary(grouping: dataController.hosts, by: { $0.platform })
            .mapValues { $0.count }
        
        return counts.map { PlatformCount(platform: $0.key, count: $0.value) }
    }
    
    struct PlatformCount: Identifiable {
        let id = UUID()
        let platform: String
        let count: Int
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let content: AnyView
    
    init(title: String, value: String, icon: String, color: Color, @ViewBuilder content: () -> some View) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.content = AnyView(content())
    }

    init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.content = AnyView(Text(value).font(.title).bold())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            content
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}
