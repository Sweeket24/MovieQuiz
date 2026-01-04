//
//  MoviesLoading.swift
//  MovieQuiz
//
//  Created by Федор Терехин on 27.12.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)

