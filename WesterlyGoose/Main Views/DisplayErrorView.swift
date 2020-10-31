//
//  DisplayErrorView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 31/10/20.
//

import SwiftUI

struct DisplayErrorView: View {
    @ObservedObject var model: UserModel
    var body: some View {
        VStack {
            Spacer()
            Text("An error has occurred.").font(.title).padding()
            Text("Error: \(model.lastError.description)").font(.body)
            Spacer()
            Button("Restart") {
                self.restart()
            }
        }
    }
    func restart() {
        model.requestUserName(reset: true)
    }
}

struct DisplayErrorView_Previews: PreviewProvider {
    struct DisplayErrorViewHost: View {
        @StateObject var model: UserModel
        var body: some View {
            DisplayErrorView(model: model)
        }
    }
    static var previews: some View {
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .noError))
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .badHTTPResponse(100)))
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .userCancelled))
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .noUserNameSpecified))
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .urlMalformed("xxx")))
        DisplayErrorViewHost(model: UserModel(state: .displayError, error: .unexpectedError(TestError.testing)))
    }
}

fileprivate extension UserModel {
    convenience init(state: FetchUserStateEnum, error: FetchUserStateError) {
        self.init()
        self.userName = "Test User"
        self.state = state
        self.lastError = error
    }
}

fileprivate enum TestError: Error {
    case testing
    var description: String {
        "Testing"
    }
}
