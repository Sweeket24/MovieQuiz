//
//  Extensions.swift
//  MovieQuiz
//
//  Created by Федор Терехин on 27.12.2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
