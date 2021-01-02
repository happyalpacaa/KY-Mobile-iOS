import Foundation
import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var currentUser = ProfileViewModel()
    
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false

    @State private var isShowingEditProfile: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color("VeryLightGrey")
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    
                    Section(header: Text("Profile")
                                .font(.system(size: 34, weight: .bold, design: .default))
                                .bold()
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .foregroundColor(Color("Black"))) {
                        NavigationLink(destination: EditProfileView(currentUser: currentUser.currentUser,
                                                                    errorMessage: $errorMessage,
                                                                    showErrorMessage: $showErrorMessage,
                                                                    isShowingEditProfile: $isShowingEditProfile), isActive: $isShowingEditProfile) {
                            ProfileCardView(user: currentUser.currentUser)
                        }
                    }.textCase(nil)
                    
                    Section() {
                        
                        NavigationLink(destination: SavedPostsView()) {
                            Label {
                                Text("Saved Posts")
                            } icon: {
                                Image(systemName: "bookmark")
                                    .renderingMode(.original)
                            }
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            Label {
                                Text("Settings")
                            } icon: {
                                Image(systemName: "gear")
                                    .renderingMode(.original)
                            }
                        }
                        
                        NavigationLink(destination: FeedbackView()) {
                            Label {
                                Text("Feedback")
                            } icon: {
                                Image(systemName: "message.circle")
                                    .renderingMode(.original)
                            }
                        }
                    }
                    
                    Section() {
                        HStack {
                            Button("Logout") {
                                FBAuthFunctions.logout { (result) in
                                }}
                        }
                    }
                }
            }.navigationBarHidden(true)
        }
    }
}

struct ProfileCardView: View {

    let user: User
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 40

    var body: some View {
        HStack (spacing: 12) {
            UserCardImage(url: user.Image)
            VStack (spacing: 3) {
                name
                email
                studentID
                batch
            }
        }
    }

    var name: some View {
        HStack {
            VStack(alignment: .leading){
                Text("\(user.Name)")
                    .lineLimit(2)
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(Color("Black"))
            }
            Spacer()
        }
    }

    var email: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(user.Email)
                    .lineLimit(2)
                    .font(.system(size: 12))
                    .foregroundColor(Color("DarkGrey"))
            }
            Spacer()
        }
    }

    var studentID: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("#\(user.StudentID)")
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(Color("DarkGrey"))
            }
            Spacer()
        }
    }
    
    var batch: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Batch \(user.Batch)")
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(Color("DarkGrey"))
            }
            Spacer()
        }
    }
}

struct UserCardImage: View {
    @ObservedObject var imageLoader = ImageLoaderViewModel()
    let url: String
    let placeholder: String

    init(url: String, placeholder: String = "placeholder") {
        self.url = url
        self.placeholder = placeholder
        self.imageLoader.downloadImage(url: self.url)
    }

    var body: some View {
        if let data = self.imageLoader.downloadedData {
            return Image(uiImage: UIImage(data: data)!).userCardImageModifier()
        } else {
            return Image("placeholder").userCardImageModifier()
        }
    }
}

extension Image {
    func userCardImageModifier() -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(lineWidth: 0.5))
   }
}
