//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Федор Терехин on 24.12.2025.
//

import Foundation


struct ServerError: Error {
    let messageError: String
    var localizedDescription: String {
        return messageError
    }
}

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if mostPopularMovies.errorMessage.isEmpty {
                        handler(.success(mostPopularMovies))
                    } else {
                        let error = ServerError(messageError: mostPopularMovies.errorMessage)
                        handler(.failure(error))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
