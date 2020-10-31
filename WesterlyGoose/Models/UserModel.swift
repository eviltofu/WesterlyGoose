//
//  FetchUserModel.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 27/10/20.
//

import Combine
import Foundation

enum FetchUserStateEnum {
    case requestUserName, fetchingUser, fetchedUserOk, displayUserOk, displayError, fetchingRepos
}

/*
 State machine of this view
 
 (*) -> requestUserName
 requestUserName -(press fetch button)-> fetchingUser
 fetchingUser -(completed download)-> fetchedUserOk
 fetchingUser -(error in download)-> fetchedError
 fetchingUser -(press cancel button) -> displayError
 displayError -(press restart button)-> requestUserName
 fetchedUserOk -()-> fetchingRepos
 fetchingRepos -(completed download)-> displayUserOk
 fetchingRepos -(error in download)-> fetchedError
 fetchingRepos -(press cancel button)-> fetchedError
 displayUserOk -(press restart button)-> requestUserName
 
 */

enum FetchUserStateError: Error {
    case noError
    case badHTTPResponse(Int)
    case userCancelled
    case noUserNameSpecified
    case urlMalformed(String)
    case unexpectedError(Error)
    
    var description: String {
        switch self {
        case .noError:
            return "No error"
        case .badHTTPResponse(let responseCode):
            return "Bad response code \(responseCode)"
        case .userCancelled:
            return "User cancelled"
        case .noUserNameSpecified:
            return "No user name specified"
        case .urlMalformed(let url):
            return "URL is malformed \(url)"
        case .unexpectedError(let error):
            return "\(error)"
        }
    }
}

class UserModel: ObservableObject {
    @Published var state: FetchUserStateEnum = .requestUserName
    @Published var userName: String? = nil
    @Published var gitHubUser: GitHubUser? = nil
    @Published var gitHubUserRepos: [GitHubUserRepoModel]? = nil
    
    var cancellable: AnyCancellable? = nil
    var lastError: FetchUserStateError = .noError
    
    init() {
        requestUserName(reset: true)
    }
    
    convenience init(userName: String) {
        self.init()
        self.userName = userName
        requestUserName()
    }
    
    convenience init(userName: String, state: FetchUserStateEnum) {
        self.init()
        self.userName = userName
        self.state = state
    }
    
    func requestUserName(reset: Bool = false) {
        if reset {
            resetModel()
        }
        state = .requestUserName
    }
    
    func fetchingUser(userName: String) {
        if [.requestUserName].contains(state) {
            self.userName = userName
            state = .fetchingUser
            self.fetchUserData()
        } else {
            requestUserName(reset: true)
        }
    }
    
    func fetchedUserOk() {
        if [.fetchingUser].contains(state) {
            state = .fetchedUserOk
            self.fetchingRepos()
        } else {
            requestUserName(reset: true)
        }
    }
    
    func displayUserOk() {
        if [.fetchingRepos].contains(state) {
            state = .displayUserOk
        } else {
            requestUserName(reset: true)
        }
    }
    
    func displayError() {
        if [.fetchingUser,.fetchingRepos].contains(state) {
            state = .displayError
        } else {
            requestUserName(reset: true)
        }
    }
    
    func fetchingRepos() {
        if [.fetchedUserOk].contains(state) {
            state = .fetchingRepos
            self.fetchReposData()
        } else {
            requestUserName(reset: true)
        }
    }
        
    private func fetchUserData() {
        guard let userName = self.userName, !userName.isEmpty else {
            self.lastError = FetchUserStateError.noUserNameSpecified
            self.displayError()
            return
        }
        let urlString = "https://api.github.com/users/\(userName)"
        guard let url = URL(string: urlString) else {
            self.lastError = FetchUserStateError.urlMalformed(urlString)
            self.displayError()
            return
        }
        lastError = .noError
        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) == false {
                    throw FetchUserStateError.badHTTPResponse(response.statusCode)
                }
                return data
            }
            .decode(type: GitHubUser.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    if let expectedError = error as? FetchUserStateError {
                        self.lastError = expectedError
                    } else {
                        self.lastError = .unexpectedError(error)
                    }
                    self.displayError()
                case .finished:
                    break
                }
            }, receiveValue: { (user) in
                self.gitHubUser = user
                self.fetchedUserOk()
            })
    }
    
    private func fetchReposData() {
        guard let userName = self.userName, !userName.isEmpty else {
            self.lastError = FetchUserStateError.noUserNameSpecified
            self.displayError()
            return
        }
        let urlString = "https://api.github.com/users/\(userName)/repos"
        guard let url = URL(string: urlString) else {
            self.displayError()
            return
        }
        lastError = .noError
        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) == false {
                    throw FetchUserStateError.badHTTPResponse(response.statusCode)
                }
                return data
            }
            .decode(type: [GitHubUserRepoModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    if let expectedError = error as? FetchUserStateError {
                        self.lastError = expectedError
                    } else {
                        self.lastError = .unexpectedError(error)
                    }
                    self.displayError()
                case .finished:
                    break
                }
            }, receiveValue: { (repos) in
                self.gitHubUserRepos = repos
                self.displayUserOk()            })
    }
    
    private func resetURLFetchingMechanism() {
        lastError = .noError
        cancellable?.cancel()
        cancellable = nil
    }
    
    private func resetModel() {
        resetURLFetchingMechanism()
        userName = nil
        gitHubUser = nil
        gitHubUserRepos = nil
    }
}
