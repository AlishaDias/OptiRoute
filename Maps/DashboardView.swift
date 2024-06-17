import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DeliveryViewModel
    @Binding var isLoggedIn: Bool
    @State private var selectedTab: String = "Pending"
    var onStartNewRoute: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Spacer()
                    Text("Welcome user! This is your order status as of \(formattedDate())").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn)) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.trailing, 20)
                }

                Picker("Select Tab", selection: $selectedTab) {
                    Text("Pending").tag("Pending")
                    Text("Ongoing").tag("Ongoing")
                    Text("Completed").tag("Completed")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(viewModel.deliveries.filter { $0.status == selectedTab }) { delivery in
                        DeliveryRow(delivery: delivery, viewModel: viewModel)
                    }
                }
                
                Button(action: onStartNewRoute) {
                    Text("View Map")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding()
            }
            .navigationTitle("Orders")
            .foregroundColor(.black)
        }
        .fullScreenCover(isPresented: Binding(get: { !isLoggedIn }, set: { isLoggedIn = !$0 })) {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }
}

struct DeliveryRow: View {
    var delivery: Delivery
    @ObservedObject var viewModel: DeliveryViewModel
    
    var body: some View {
        NavigationLink(destination: DeliveryDetailView(delivery: delivery, viewModel: viewModel)) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Order #\(delivery.id)")
                    Text("Name: \(delivery.name)")
                    Text("Delivery time: \(delivery.time)")
                }
                Spacer()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    @State static var isLoggedIn = true

    static var previews: some View {
        DashboardView(viewModel: DeliveryViewModel(), isLoggedIn: $isLoggedIn, onStartNewRoute: {})
    }
}
