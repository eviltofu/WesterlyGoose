//
//  RequestUserNameView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 27/10/20.
//

import SwiftUI

struct RequestUserNameView: View {
    @State var userName: String = ""
    @ObservedObject var model: UserModel
    var body: some View {
        VStack {
            Spacer()
            Text("Name of user to fetch")
            TextField("User name", text: $userName)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Spacer()
            Button("Fetch") {
                self.fetchUser()
            }
        }
    }
    private func fetchUser() {
        model.fetchingUser(userName: userName)
    }
}

struct RequestUserNameView_Previews: PreviewProvider {
    struct RequestUserNameViewHost: View {
        @StateObject var model = UserModel(userName: "ABC")
        var body: some View {
            RequestUserNameView(model: model)
        }
    }
    
    static var previews: some View {
        RequestUserNameViewHost()
    }
}
