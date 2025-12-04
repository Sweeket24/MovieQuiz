//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Федор Терехин on 28.11.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
