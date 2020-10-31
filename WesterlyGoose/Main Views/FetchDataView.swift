//
//  FetchDataView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 29/10/20.
//

import SwiftUI

struct FetchDataView: View {
    @ObservedObject var model: UserModel
    var body: some View {
        VStack {
            Spacer()
            if model.userName == nil {
                Text("Error: user name is not set!")
            } else
            if [.fetchingUser].contains(model.state) {
                Text("Fetching user data for \(model.userName!)")
            } else
            if [.fetchedUserOk].contains(model.state) {
                Text("Fetched user data for \(model.userName!)")
            } else
            if [.fetchingRepos].contains(model.state) {
                Text("Fetching repos data for \(model.userName!)")
            } else {
                Text("FetchDataView Error: Unexpected state \(String(describing: model.state))")
            }
            Spacer()
            Button("Reset") {
                self.restart()
            }
        }
    }
    
    private func restart() {
        model.requestUserName(reset: true)
    }
}

struct FetchDataView_Previews: PreviewProvider {
    struct FetchDataViewHost: View {
        @StateObject var model: UserModel
        var body: some View {
            FetchDataView(model: model)
        }
    }
    
    static var previews: some View {
        FetchDataViewHost(model: UserModel(state: .fetchingUser))
        FetchDataViewHost(model: UserModel(state: .fetchingRepos))
        FetchDataViewHost(model: UserModel(userName: "ABC", state: .fetchingUser))
        FetchDataViewHost(model: UserModel(userName: "DEF", state: .fetchingRepos))
        FetchDataViewHost(model: UserModel(userName: "GHI", state: .requestUserName))
        FetchDataViewHost(model: UserModel(userName: "JKL", state: .fetchedUserOk))
        FetchDataViewHost(model: UserModel(userName: "PQR", state: .displayUserOk))
        FetchDataViewHost(model: UserModel(userName: "STU", state: .displayError))
    }
}

fileprivate extension UserModel {
    convenience init(state: FetchUserStateEnum) {
        self.init()
        self.userName = nil
        self.state = state
    }
}

