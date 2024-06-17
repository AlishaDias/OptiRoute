import SwiftUI

struct DeliveryDetailView: View {
    var delivery: Delivery
    @ObservedObject var viewModel: DeliveryViewModel
    
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order #\(delivery.id)")
                .font(.headline)
            Text("Name: \(delivery.name)")
            Text("Delivery time: \(delivery.time)")
            Text("Location: \(delivery.location)")
            
            Spacer()
            
            HStack {
                Button(action: {
                    viewModel.acceptDelivery(delivery)
                }) {
                    Text("Accept")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.removeDelivery(id: delivery.id)
                }) {
                    Text("Reject")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.completeDelivery(delivery)
                    showAlert = true
                }) {
                    Text("Completed")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("That's Awesome!"),
                        message: Text("You completed order number \(delivery.id)."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle("Order Details")
    }
}
