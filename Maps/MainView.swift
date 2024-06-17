import SwiftUI

struct MainView: View {
    @State private var isLoggedIn = false
    @State private var showContentView = false
    @StateObject private var viewModel = DeliveryViewModel()
    
    var body: some View {
        Group {
            if showContentView {
                ContentView(viewModel: viewModel, onDone: {
                    showContentView = false
                })
            } else if isLoggedIn {
                DashboardView(viewModel: viewModel, isLoggedIn: $isLoggedIn, onStartNewRoute: {
                    showContentView = true
                })
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
