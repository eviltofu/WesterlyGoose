//
//  DisplayDataView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 29/10/20.
//

import SwiftUI

struct DisplayDataView: View {
    @ObservedObject var model: UserModel
    var body: some View {
        VStack {
            userImage().padding(.top)
            name()
            userName().padding(.top)
            email()
            repos().padding()
            Spacer()
            Button("Fetch another user?") {
                self.reset()
            }
        }
    }
    
    private func reset() {
        model.requestUserName(reset: true)
    }
    
    private func userImage() -> some View {
        if model.gitHubUser != nil {
            return AnyView(URLImageView(
                urlString: model.gitHubUser!.imageURLString(),
                resizable: true,
                preloadImage: UIImage(systemName: "person.fill")!,
                loadingImage: UIImage(systemName: "person.crop.circle.fill")!,
                errorImage: UIImage(systemName: "person.crop.circle.fill.badge.xmark")!
            )
            .scaledToFill()
            .frame(width: 128.0, height: 128.0, alignment: .center)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 4.0)
                        .foregroundColor(.black)))
        } else {
            return AnyView(Text("No image available"))
        }
    }
    
    private func userName() -> some View {
        if model.gitHubUser != nil {
            return AnyView(Text("\(model.gitHubUser!.userNameString())"))
        } else {
            return AnyView(Text("No user name available"))
        }
    }
    
    private func email() -> some View {
        if model.gitHubUser != nil {
            return AnyView(Text("\(model.gitHubUser!.emailString())"))
        } else {
            return AnyView(Text("No user email available"))
        }
    }
    
    private func name() -> some View {
        if model.gitHubUser != nil {
            return AnyView(Text("\(model.gitHubUser!.nameString())"))
        } else {
            return AnyView(Text("No name available"))
        }
    }

    private func repos() -> some View {
        if model.gitHubUserRepos != nil {
            return AnyView(
                Group {
                    List(model.gitHubUserRepos!) { repo in
                        HStack {
                            Text(repo.repoDescriptionString()).multilineTextAlignment(.leading)
                        }
                    }
                    .border(Color.black)
                })
        } else {
            return AnyView(Text("No repos present."))
        }
    }
}

struct DisplayDataView_Previews: PreviewProvider {
    struct DisplayDataViewHost: View {
        @StateObject var model: UserModel
        var body: some View {
            DisplayDataView(model: model)
        }
    }
    static var previews: some View {
        DisplayDataViewHost(model:
                                UserModel(
                                    userName: "ABC",
                                    state: .displayUserOk,
                                    user:
                                        GitHubUser(
                                            name: "Jerome Chan",
                                            userName: "ABC",
                                            imageURL: "https://imagej.nih.gov/ij/images/baboon.jpg",
                                            email: "ABC@sample.com"),
                                    repos: [
                                        GitHubUserRepoModel(
                                            id: 1,
                                            name: "Repo 1",
                                            repoDescription: "This is repo 1"),
                                        GitHubUserRepoModel(
                                            id: 2,
                                            name: "Repo 2",
                                            repoDescription: "This is repo 2"),
                                        GitHubUserRepoModel(
                                            id: 3,
                                            name: "Repo 3",
                                            repoDescription: "This is repo 3")
                                    ]))
        DisplayDataViewHost(model:
                                UserModel(
                                    userName: "DEF",
                                    state: .displayUserOk,
                                    user:
                                        GitHubUser(
                                            userName: "ABC",
                                            imageURL: nil,
                                            email: nil),
                                    repos: nil))
        DisplayDataViewHost(model:
                                UserModel(
                                    userName: "GHI",
                                    state: .displayUserOk,
                                    user: nil,
                                    repos: nil))
    }
}

fileprivate extension UserModel {
    convenience init(userName: String, state: FetchUserStateEnum, user: GitHubUser?, repos: [GitHubUserRepoModel]?) {
        self.init()
        self.userName = userName
        self.state = state
        self.gitHubUser = user
        self.gitHubUserRepos = repos
    }
}
