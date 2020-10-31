//
//  FetchUserView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 27/10/20.
//

import SwiftUI

struct FetchUserView: View {
    @StateObject var model = UserModel()
    var body: some View {
        if [.requestUserName].contains(model.state) {
            RequestUserNameView(model: model).padding()
        }
        if [.fetchingUser, .fetchedUserOk, .fetchingRepos].contains(model.state) {
            FetchDataView(model: model).padding()
        }
        if [.displayUserOk].contains(model.state) {
            DisplayDataView(model: model)
        }
        if [.displayError].contains(model.state) {
            DisplayErrorView(model: model).padding()
        }
    }
}

struct FetchUserView_Previews: PreviewProvider {
    static var previews: some View {
        FetchUserView()
    }
}
