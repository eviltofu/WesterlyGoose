//
//  ImageLoadingView.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 29/10/20.
//

import SwiftUI
import Combine

enum ImageLoadingViewModelState {
    case waiting, started, completed, error
}

enum ImageLoadingViewModelError: Error {
    case noError
    case badHTTPResponse(Int)
    case badImageData
}

class ImageLoadingViewModel: ObservableObject {
    @Published var state: ImageLoadingViewModelState = .waiting
    @Published var image: UIImage?
    func start() {
        preconditionFailure("This method must be overridden")
    }
}

fileprivate class ImageLoadingViewStaticStateModel: ImageLoadingViewModel {
    init(state newState: ImageLoadingViewModelState) {
        super.init()
        state = newState
    }
    override func start() {
    }
}

fileprivate class ImageLoadingViewStaticImageModel: ImageLoadingViewModel {
    init(image newImage: UIImage) {
        super.init()
        state = .completed
        image = newImage
    }
    override func start() {
    }
}

class ImageLoadingViewURLStringModel: ImageLoadingViewModel {
    var urlString: String
    var cancellable: AnyCancellable? = nil
    init(urlString: String) {
        self.urlString = urlString
    }
    override func start() {
        state = .started
        loadImage()
    }
    func loadImage() {
        guard let url = URL(string: urlString) else {
            state = .error
            return
        }
        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> UIImage in
                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) == false {
                    throw ImageLoadingViewModelError.badHTTPResponse(response.statusCode)
                }
                guard let image = UIImage(data: data) else {
                    throw ImageLoadingViewModelError.badImageData
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure:
                    self.image = nil
                    self.state = .error
                case .finished:
                    break
                }
            }, receiveValue: { (image) in
                self.image = image
                self.state = .completed
            })
    }
}

fileprivate struct ImageLoadingView: View {
    @StateObject var model: ImageLoadingViewModel
    var resizable: Bool
    var preloadImage: UIImage
    var loadingImage: UIImage
    var errorImage: UIImage
    var body: some View {
        if model.state == .waiting {
            withResizable(image: preloadImage).onAppear{model.start()}
        } else
        if model.state == .started {
            withResizable(image: loadingImage)
        } else
        if let image = model.image, model.state == .completed {
            withResizable(image: image)
        } else {
            withResizable(image: errorImage).padding()
        }
    }
    func withResizable(image: UIImage) -> Image {
        resizable ? Image(uiImage: image).resizable() : Image(uiImage: image)
    }
    static func with(urlString: String, resizable: Bool) -> some View {
        ImageLoadingView(model: ImageLoadingViewURLStringModel(urlString: urlString),
                         resizable: resizable,
                         preloadImage: URLImageView.preloadImage,
                         loadingImage: URLImageView.loadingImage,
                         errorImage: URLImageView.errorImage)
    }
    static func with(state: ImageLoadingViewModelState, resizable: Bool) -> some View {
        ImageLoadingView(model: ImageLoadingViewStaticStateModel(state: state),
                         resizable: resizable,
                         preloadImage: URLImageView.preloadImage,
                         loadingImage: URLImageView.loadingImage,
                         errorImage: URLImageView.errorImage)
    }
    static func with(image: UIImage, resizable: Bool) -> some View {
        ImageLoadingView(model: ImageLoadingViewStaticImageModel(image: image),
                         resizable: resizable,
                         preloadImage: URLImageView.preloadImage,
                         loadingImage: URLImageView.loadingImage,
                         errorImage: URLImageView.errorImage)
    }
}

struct URLImageView: View {
    static let preloadImage: UIImage = UIImage(systemName: "photo")!
    static let loadingImage: UIImage = UIImage(systemName: "icloud.and.arrow.down")!
    static let errorImage: UIImage = UIImage(systemName: "xmark.icloud")!
    var urlString: String
    var resizable: Bool
    var preloadImage: UIImage = URLImageView.preloadImage
    var loadingImage: UIImage = URLImageView.loadingImage
    var errorImage: UIImage = URLImageView.errorImage
    init(urlString: String) {
        self.urlString = urlString
        self.resizable = false
    }
    init(urlString: String,
         resizable: Bool) {
        self.urlString = urlString
        self.resizable = resizable
    }
    init(urlString: String,
         resizable: Bool,
         preloadImage: UIImage,
         loadingImage: UIImage,
         errorImage: UIImage) {
        self.urlString = urlString
        self.resizable = resizable
        self.preloadImage = preloadImage
        self.loadingImage = loadingImage
        self.errorImage = errorImage
    }
    var body: some View {
        ImageLoadingView(model: ImageLoadingViewURLStringModel(urlString: urlString),
                         resizable: resizable,
                         preloadImage: preloadImage,
                         loadingImage: loadingImage,
                         errorImage: errorImage)
    }
}

struct ImageLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoadingView.with(state: .waiting, resizable: false)
            .scaledToFit()
        ImageLoadingView.with(state: .started, resizable: false)
            .scaledToFit()
        ImageLoadingView.with(state: .completed, resizable: false)
            .scaledToFit()
        ImageLoadingView.with(state: .error, resizable: false)
            .scaledToFit()
        ImageLoadingView.with(image: UIImage(named: "demo")!, resizable: false)
            .scaledToFit()
        URLImageView(urlString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Limenitis_archippus_Cramer.jpg/1920px-Limenitis_archippus_Cramer.jpg", resizable: true)
            .frame(width: 320.0, height: 320.0, alignment: .center)
            .scaledToFit()
            .clipShape(Circle())
            .padding(.all, 16.0)
            .border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
        URLImageView(urlString: "does not exist", resizable: true)
            .scaledToFit()
            .padding()
            .frame(width: 128.0, height: 128.0, alignment: .center)
            .clipShape(Circle())
            .overlay(Circle()
                        .stroke(Color.red, lineWidth: 4.0)
                        .foregroundColor(.red))
    }
}
