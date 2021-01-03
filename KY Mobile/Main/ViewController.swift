import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ViewController: View {
    @EnvironmentObject var currentUserInfo: CurrentUserInfo
    @State private var currentTab: Int = 0
    
    var body: some View {
        
        Group {
            
            if currentUserInfo.isUserAuthenticated == .undefined {
                Text("Loading...")
            }
            else if currentUserInfo.isUserAuthenticated == .signedOut {
                IntroductionView()
            }
            else {
                // Controls which page will be displayed using the bottom navigation bar
                TabView {
                    HomeView()
                        .tabItem({
                            Image(systemName: "house")
                                .font(.system(size: 20))
                            Text("Home")
                        }).tag(0)

                    CurrentView()
                        .tabItem({
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                            Text("Current")
                        }).tag(1)

                    NoticeView()
                        .tabItem({
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                            Text("Notices")
                        }).tag(2)

                    ProfileView()
                        .tabItem({
                            Image(systemName: "person")
                                .font(.system(size: 20))
                            Text("Profile")
                        }).tag(3)
                }
            }
        }.onAppear {
            // Allow app to react if user signs out or signs in
            self.currentUserInfo.configureFirebaseStateDidChange()
        }
    }
}