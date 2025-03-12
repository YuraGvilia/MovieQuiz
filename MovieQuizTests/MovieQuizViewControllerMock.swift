//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Yura Gvilia on 09.03.2025.
//

import UIKit
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var quizStep: QuizStepViewModel?
    var quizResults: QuizResultsViewModel?
    var didShowLoadingIndicator = false
    var didHideLoadingIndicator = false
    var networkErrorMessage: String?
    var didHighlightImageBorder: Bool?

    func show(quiz step: QuizStepViewModel) {
        quizStep = step
    }
    
    func show(quiz result: QuizResultsViewModel) {
        quizResults = result
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        didHighlightImageBorder = isCorrectAnswer
    }
    
    func showLoadingIndicator() {
        didShowLoadingIndicator = true
    }
    
    func hideLoadingIndicator() {
        didHideLoadingIndicator = true
    }
    
    func showNetworkError(message: String) {
        networkErrorMessage = message
    }
}
