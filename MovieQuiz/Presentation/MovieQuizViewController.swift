//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 09.03.2025.
//

import UIKit

final class MovieQuizViewController: UIViewController,
                                    MovieQuizViewControllerProtocol,
                                    AlertPresenterDelegate
{
    // MARK: - UI Elements (IBOutlet)
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    // MARK: - MVP Presenter
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Alert Presenter
    private var alertPresenter: AlertPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Индикатор скрывается, когда останавливается
        activityIndicator.hidesWhenStopped = true
        
        // Инициализируем Presenter (MVP)
        presenter = MovieQuizPresenter(viewController: self)
        
        // Инициализируем AlertPresenter и передаём делегата
        alertPresenter = AlertPresenter(delegate: self)
        
        // Настраиваем UI (ImageView и т.д.)
        setupUI()

        // Устанавливаем Accessibility Identifiers с задержкой, чтобы UI успел загрузиться
        DispatchQueue.main.async {
            self.setupAccessibilityIdentifiers()
        }

        // Показываем индикатор
        showLoadingIndicator()
    }

    // MARK: - Настройка UI
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Устанавливаем идентификаторы для UI-тестов (проверка на `nil`)
    private func setupAccessibilityIdentifiers() {
        imageView.accessibilityIdentifier = "Poster"
        
        if let counterLabel = counterLabel {
            counterLabel.accessibilityIdentifier = "Index"
        } else {
            print("⚠ Ошибка: counterLabel не найден в Storyboard!")
        }

        if let yesButton = yesButton {
            yesButton.accessibilityIdentifier = "YesButton"
        } else {
            print("⚠ Ошибка: yesButton не найден в Storyboard!")
        }

        if let noButton = noButton {
            noButton.accessibilityIdentifier = "NoButton"
        } else {
            print("⚠ Ошибка: noButton не найден в Storyboard!")
        }
    }

    // MARK: - MovieQuizViewControllerProtocol (MVP)
    func show(quiz step: QuizStepViewModel) {
        // Сбрасываем цвет рамки
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        // Обновляем UI
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        guard let alertPresenter = alertPresenter else {
            print("⚠ Ошибка: `alertPresenter` = nil, алерт не будет показан!")
            return
        }

        let message = presenter.makeResultsMessage()
        alertPresenter.showResultAlert(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.presenter.restartGame()
        }
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        // Берём цвета из ассетов (или fallback)
        let correctColor = UIColor(named: "QuizBorderColorCorrect") ?? UIColor.green
        let incorrectColor = UIColor(named: "QuizBorderColorIncorrect") ?? UIColor.red
        
        imageView.layer.borderColor = isCorrectAnswer ? correctColor.cgColor : incorrectColor.cgColor
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        // Проверка, что алерт-презентер существует
        guard let alertPresenter = alertPresenter else {
            print("⚠ Ошибка: `alertPresenter` = nil, алерт не будет показан!")
            return
        }

        // Показываем алерт об ошибке
        alertPresenter.showResultAlert(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            self?.presenter.restartGame()
        }
    }

    // MARK: - User Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    // MARK: - AlertPresenterDelegate
    func presentAlert(_ alert: UIAlertController) {
        // Показываем алерт
        present(alert, animated: true)
    }

    // MARK: - Стиль статус-бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
