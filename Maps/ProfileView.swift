import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .padding()

            Text("User Name")
                .font(.title)
                .fontWeight(.bold)
            
            Text("user@example.com")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: ProfileDetailView()) {
                Text("Edit Profile")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Button(action: {
                // Log out action
                isLoggedIn = false
            }) {
                Text("Log Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var isLoggedIn = true

    static var previews: some View {
        ProfileView(isLoggedIn: $isLoggedIn)
    }
}

struct ProfileDetailView: View {
    var body: some View {
        Text("Profile Details")
            .font(.largeTitle)
    }
}
