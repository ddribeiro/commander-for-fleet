import SwiftUI

struct TopLevelNavigationView: View {
    var body: some View {
        NavigationLink(value: Panel.home) {
            Label("Home", systemImage: "house")
        }

        NavigationLink(value: Panel.hosts) {
            Label("Hosts", systemImage: "laptopcomputer")
        }

        NavigationLink(value: Panel.users) {
            Label("Users", systemImage: "person.2")
        }

        NavigationLink(value: Panel.software) {
            Label("Software", systemImage: "square.stack.3d.up")
        }

        NavigationLink(value: Panel.queries) {
            Label("Queries", systemImage: "rectangle.and.text.magnifyingglass")
        }

        NavigationLink(value: Panel.policies) {
            Label("Policies", systemImage: "checkmark.seal")
        }
    }
}

#Preview {
    TopLevelNavigationView()
}
