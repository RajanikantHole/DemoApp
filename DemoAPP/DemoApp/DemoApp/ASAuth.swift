import SwiftUI
import AuthenticationServices

struct ASAuth: View {
    @State private var authSession: ASWebAuthenticationSession?
    @State private var resultText = "Not logged in"

    var body: some View {
        VStack(spacing: 20) {
            Text(resultText)
                .padding()
            
            Button("Login with Google") {
                startGoogleLogin()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    func startGoogleLogin() {
        // 🔹 Replace with your own Google OAuth client ID
        let clientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
        let redirectURI = "myapp://callback"
        
        // 🔹 Google OAuth endpoint
        let authURL = URL(string:
            "https://accounts.google.com/o/oauth2/v2/auth?" +
            "response_type=token&" +
            "client_id=\(clientID)&" +
            "redirect_uri=\(redirectURI)&" +
            "scope=openid%20email%20profile"
        )!
        
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "myapp"
        ) { callbackURL, error in
            if let callbackURL = callbackURL {
                // Extract access token from URL fragment
                if let fragment = callbackURL.fragment {
                    let params = fragment
                        .split(separator: "&")
                        .map { $0.split(separator: "=") }
                        .reduce(into: [String: String]()) { dict, pair in
                            if pair.count == 2 {
                                dict[String(pair[0])] = String(pair[1])
                            }
                        }
                    if let token = params["access_token"] {
                        resultText = "✅ Logged in!\nToken: \(token)"
                    } else {
                        resultText = "⚠️ No token found in callback"
                    }
                }
            } else {
                resultText = "❌ Login canceled or failed"
            }
        }
        
        // Required for presentation
        authSession?.presentationContextProvider = ContextProvider()
        authSession?.start()
    }
}

// 🔹 Provide a window for presenting the Safari sheet
class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
}
