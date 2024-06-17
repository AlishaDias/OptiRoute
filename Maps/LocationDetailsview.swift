import SwiftUI
import MapKit

struct LocationDetailsView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var getDirections: Bool
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Spacer()
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                Spacer()
                
            }
            HStack() {
                Button {
                    if let mapSelection {
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(.orange)
                        .cornerRadius(12)
                }
                Button {
                    getDirections = true
                    show = false
                } label: {
                    Text("Get Directions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(.orange)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct LocationDetailsView_Previews: PreviewProvider {
    @State static var mapSelection: MKMapItem? = {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        return MKMapItem(placemark: placemark)
    }()
    @State static var getDirections = false
    @State static var show = true
    
    static var previews: some View {
        LocationDetailsView(mapSelection: $mapSelection, getDirections: $getDirections, show: $show)
            .previewLayout(.sizeThatFits)
    }
}
