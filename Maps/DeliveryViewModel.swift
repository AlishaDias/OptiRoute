import SwiftUI
import MapKit

struct Delivery: Identifiable {
    var id: UUID
    var name: String
    var time: String
    var location: String
    var status: String
}

// ViewModel to manage deliveries
class DeliveryViewModel: ObservableObject {
    @Published var deliveries: [Delivery] = [
        Delivery(id: UUID(), name: "John Doe", time: "10am-3pm", location: "6230 N Kenmore Ave Chicago Illinois 60660", status: "Pending"),
        Delivery(id: UUID(), name: "Jane Doe", time: "5pm-10pm", location: "2250 N Sheffield Ave Chicago Illinois 60614", status: "Pending"),
        Delivery(id: UUID(), name: "Alisha Dias", time: "10am-1pm", location: "6230 N Kenmore Ave Chicago Illinois 60660", status: "Pending"),
        Delivery(id: UUID(), name: "Manvi Koli", time: "10am-3pm", location: "6230 N Kenmore Ave Chicago Illinois 60660", status: "Pending"),
        Delivery(id: UUID(), name: "James Adams", time: "10am-3pm", location: "1 E Jackson Blvd Chicago Illinois 60604", status: "Pending"),
        Delivery(id: UUID(), name: "Manvi Koli", time: "10am-3pm", location: "6230 N Kenmore Ave Chicago Illinois 60660", status: "Completed"),
    ]
    
    @Published var acceptedAddresses: [String] = []
    
    // Function to geocode addresses
    func getCoordinates(addresses: [String], completion: @escaping ([MKMapItem]) -> Void) {
        let geocoder = CLGeocoder()
        var mapItems: [MKMapItem] = []
        let dispatchGroup = DispatchGroup()
        
        for address in addresses {
            dispatchGroup.enter()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItems.append(mapItem)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(mapItems)
        }
    }
    
    func acceptDelivery(_ delivery: Delivery) {
        if let index = deliveries.firstIndex(where: { $0.id == delivery.id }) {
            deliveries[index].status = "Ongoing"
            acceptedAddresses.append(delivery.location)
        }
    }
    
    func completeDelivery(_ delivery: Delivery) {
            if let index = deliveries.firstIndex(where: { $0.id == delivery.id }) {
                deliveries[index].status = "Completed"
            }
        }
    
    func removeDelivery(id: UUID) {
        deliveries.removeAll { $0.id == id }
    }
}
