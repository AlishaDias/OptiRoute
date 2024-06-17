import SwiftUI
import MapKit

struct RouteDetailsView: View {
    let routes: [MKRoute]
    let totalTravelTime: TimeInterval

    var body: some View {
        VStack {
            Text("Total Travel Time: \(formattedTravelTime)")
                .font(.headline)
                .padding()
                .foregroundColor(.primary)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding()

            List(routes, id: \.self) { route in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(route.steps, id: \.self) { step in
                        HStack(alignment: .top) {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                            VStack(alignment: .leading) {
                                Text(step.instructions)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("\(step.distance, specifier: "%.2f") meters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Route Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedTravelTime: String {
        let hours = Int(totalTravelTime) / 3600
        let minutes = (Int(totalTravelTime) % 3600) / 60
        return "\(hours) hours \(minutes) minutes"
    }
}

struct RouteDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RouteDetailsView(routes: [], totalTravelTime: 0)
    }
}
