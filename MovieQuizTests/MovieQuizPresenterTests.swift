//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Yura Gvilia on 09.03.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Создаем мок
        let viewControllerMock = MovieQuizViewControllerMock()
        // Создаем Presenter, передавая мок вместо реального ViewController
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // Создаем тестовый вопрос
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // Тестируем метод convert
        let viewModel = presenter.convert(model: question)
        
        // Проверяем результат
        XCTAssertNotNil(viewModel.image, "Fallback image should be created from empty Data")
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
