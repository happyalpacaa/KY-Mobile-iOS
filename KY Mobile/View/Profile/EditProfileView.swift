import Foundation
import SwiftUI

struct EditProfileView: View {
    
    let currentUser: User
    
    @Binding var errorMessage: String
    @Binding var showErrorMessage: Bool
    
    @Binding var isShowingEditProfile: Bool
    
    @State private var editedUser: User = User()
    @State private var newProfilePicture: UIImage = UIImage()
    @State private var isShowingImagePicker: Bool = false
    
    var body: some View {
        ZStack {
            Color("VeryLightGrey")
                .edgesIgnoringSafeArea(.all)
            
            Form {
                Section () {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            if newProfilePicture != UIImage() {
                                Image(uiImage: newProfilePicture)
                                    .userEditProfileImageModifier()
                            } else {
                                UserEditProfileImage(url: currentUser.Image)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section () {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(editedUser.Name)
                            .foregroundColor(Color("NormalGrey"))
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(editedUser.Email)
                            .foregroundColor(Color("NormalGrey"))
                    }
                    
                    HStack {
                        Text("Student ID")
                        Spacer()
                        Text(editedUser.StudentID)
                            .foregroundColor(Color("NormalGrey"))
                    }
                    
                    HStack {
                        Text("Batch")
                        Spacer()
                        Text(editedUser.Batch)
                            .foregroundColor(Color("NormalGrey"))
                    }
                }
            }.sheet(isPresented: $isShowingImagePicker, content: {
                ImagePickerView(isPresented: $isShowingImagePicker,
                                selectedImage: $newProfilePicture)
            })
        }.onAppear(perform: {
            editedUser = currentUser
        })
        .navigationBarItems(trailing: Button(action: {
            if newProfilePicture != UIImage() {
                // Delete previous image
                FBStorage.deleteImage(location: "Users_ProfilePic",
                                      identifier: editedUser.UID,
                                      name: editedUser.Name) { (result) in
                    switch result {
                    case .failure (let error):
                        self.errorMessage = error.localizedDescription
                        self.showErrorMessage = true
                        
                    case .success:
                        // Upload new image
                        FBStorage.uploadImage(chosenImage: newProfilePicture,
                                              location: "Users_ProfilePic",
                                              identifier: editedUser.UID,
                                              name: editedUser.Name) { (result) in
                            switch result {
                            
                            case .failure (let error):
                                self.errorMessage = error.localizedDescription
                                self.showErrorMessage = true
                                
                            case .success (let url):
                                editedUser.Image = url.absoluteString
                                
                                // Save new image's URL into Firestore
                                FBProfile.mergeFBUser(uid: editedUser.UID,
                                                      info: editedUser.userToDict()) { (result) in
                                    switch result {
                                    case .failure (let error):
                                        self.errorMessage = error.localizedDescription
                                        self.showErrorMessage = true
                                        
                                    case .success:
                                        print("Successfully saved new profile picture")
                                    }
                                }
                            }
                        }
                    }
                }
            } else if !editedUser.equalTo(currentUser) {
                print("Edited details of User")
            }
            isShowingEditProfile = false
        }) {
            Text("Save")
        }.disabled((newProfilePicture == UIImage()) && editedUser.equalTo(currentUser)))
    }
}

struct UserEditProfileImage: View {
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
            return Image(uiImage: UIImage(data: data)!).userEditProfileImageModifier()
        } else {
            return Image("placeholder").userEditProfileImageModifier()
        }
    }
}

extension Image {
    func userEditProfileImageModifier() -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 0.5))
   }
}
