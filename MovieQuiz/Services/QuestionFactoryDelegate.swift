//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Федор Терехин on 26.11.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
