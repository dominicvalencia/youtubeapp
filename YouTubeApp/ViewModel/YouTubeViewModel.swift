//
//  YouTubeViewModel.swift
//  YouTubeApp
//
//  Created by Domini Valencia on 1/21/25.
//


import Foundation
import Combine

class YouTubeViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var comments: [CommentSnippet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = "AIzaSyAC0PW6h7e0EuINLBmiVUHAFOblUEVW5zs"
    var cancellables = Set<AnyCancellable>()

    func searchVideos(query: String) {
        guard !query.isEmpty else { return }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(encodedQuery)&type=video&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.videos = response.items
            }
            .store(in: &cancellables)
    }

    func fetchComments(videoId: String) {
        let urlString = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=\(videoId)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CommentThreadResponse.self, from: data)
                let comments = response.items.map { $0.snippet.topLevelComment.snippet }
                DispatchQueue.main.async {
                    self.comments = comments
                }
            } catch {
                print("Error decoding comments: \(error.localizedDescription)")
            }
        }.resume()
    }

}
