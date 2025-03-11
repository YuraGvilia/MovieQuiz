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
        
        // Инициализируем Presenter
        presenter = MovieQuizPresenter(viewController: self)
        
        // Инициализируем AlertPresenter с делегатом
        alertPresenter = AlertPresenter(delegate: self)
        
        // Настраиваем UI
        setupUI()
        
        // Устанавливаем идентификаторы для UI-тестов
        // (Убедитесь, что Outlets не nil)
        setupAccessibilityIdentifiers()
        
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
    
    private func setupAccessibilityIdentifiers() {
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        yesButton.accessibilityIdentifier = "YesButton"
        noButton.accessibilityIdentifier = "NoButton"
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    func show(quiz step: QuizStepViewModel) {
        // Сбрасываем рамку
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        // Обновляем UI
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        // Показываем итоговый экран через AlertPresenter
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
    
    // MARK: - Status Bar
    /// Делаем статус-бар видимым
    override var prefersStatusBarHidden: Bool { false }
    /// Делаем его светлым
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
