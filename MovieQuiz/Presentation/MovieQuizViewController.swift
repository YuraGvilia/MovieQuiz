//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 09.03.2025.
//

import UIKit

final class MovieQuizViewController: UIViewController,
                                    MovieQuizViewControllerProtocol,
                                    AlertPresenterDelegate {
    // MARK: - UI Elements (IBOutlet)
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!         // Должен быть подключен к лейблу "Index"
    @IBOutlet private weak var imageView: UIImageView!          // Постер
    @IBOutlet private weak var textLabel: UILabel!              // Текст вопроса
    @IBOutlet private weak var questionTitleLabel: UILabel!     // Заголовок вопроса (если нужен)
    @IBOutlet private weak var noButton: UIButton!              // Кнопка "Нет"
    @IBOutlet private weak var yesButton: UIButton!             // Кнопка "Да"
    
    // MARK: - MVP Presenter
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Alert Presenter
    private var alertPresenter: AlertPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        
        // Инициализируем Presenter и AlertPresenter
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
        
        setupUI()
        setupAccessibilityIdentifiers()
        
        showLoadingIndicator()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func setupAccessibilityIdentifiers() {
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        yesButton.accessibilityIdentifier = "YesButton"
        noButton.accessibilityIdentifier = "NoButton"
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    func show(quiz step: QuizStepViewModel) {
        // Сбрасываем рамку перед обновлением UI
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        // Здесь результат уже сформирован презентером, и result.text содержит итоговое сообщение
        alertPresenter.showResultAlert(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.presenter.restartGame()
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        // Берём цвета из Assets (если их нет, используем fallback)
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
        present(alert, animated: true)
    }
    
    // MARK: - Status Bar Style
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
