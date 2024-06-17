import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("OptiRoute")
                .font(.largeTitle)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .foregroundColor(.orange)
                .padding(.top, 20)

            Image("login_image")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()

            TextField("Username", text: $username)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(5)
                .padding(.horizontal, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(5)
                .padding(.horizontal, 20)

            Button(action: {
                if username == "User" && password == "password" {
                    isLoggedIn = true
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(4)
                    .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Login")
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoggedIn = false

    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
