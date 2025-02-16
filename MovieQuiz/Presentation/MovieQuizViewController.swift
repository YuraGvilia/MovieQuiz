// Автор: Yura Gvilia

import UIKit

// MARK: - Структуры моделей данных

/// Модель вопроса квиза
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

/// Модель состояния "Вопрос показан"
private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

/// Модель состояния "Результат квиза"
private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    // MARK: - UI Элементы
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    // MARK: - Данные
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The_Godfather", text: "Рейтинг этого фильма\nбольше чем 8?", correctAnswer: true),
        QuizQuestion(image: "The_Dark_Knight", text: "Рейтинг этого фильма\nбольше чем 9?", correctAnswer: true),
        QuizQuestion(image: "Kill_Bill", text: "Рейтинг этого фильма\nбольше чем 7?", correctAnswer: true),
        QuizQuestion(image: "The_Avengers", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма\nбольше чем 7?", correctAnswer: true),
        QuizQuestion(image: "The_Green_Knight", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The_Ice_Age_Adventures", text: "Рейтинг этого фильма\nбольше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма\nбольше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: false)
    ]

    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private var totalGamesPlayed: Int = .zero
    private var totalCorrectAnswers: Int = .zero
    private var bestScore: Int = .zero

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showNextQuestion()
    }

    // MARK: - UI Настройки
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true // Обрезает изображение по скругленным границам
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor // Изначально граница невидима
    }
    
    // MARK: - Логика игры
    private func showNextQuestion() {
        guard !questions.isEmpty else { return }

        // Очистка рамки перед сменой вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor

        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
        
        // Включаем кнопки после смены вопроса
        self.view.isUserInteractionEnabled = true
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        if let image = UIImage(named: model.image) {
            print("✅ Успешно загружено изображение: \(model.image)")
            return QuizStepViewModel(
                image: image,
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
            )
        } else {
            print("❌ Ошибка: Изображение \(model.image) не найдено! Проверь название в Assets.")
            return QuizStepViewModel(
                image: UIImage(systemName: "photo")!,
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
            )
        }
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }

    private func checkAnswer(_ answer: Bool) {
        // Отключаем кнопки сразу после нажатия
        self.view.isUserInteractionEnabled = false

        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        view.isUserInteractionEnabled = false // Блокируем нажатия

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = (isCorrect ? UIColor(hex: "#60C28E") : UIColor(hex: "#F56B6C"))?.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.view.isUserInteractionEnabled = true // Включаем обратно
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showNextQuestion()
        }
    }

    private func show(quiz result: QuizResultsViewModel) {
        totalGamesPlayed += 1
        totalCorrectAnswers += correctAnswers
        if correctAnswers > bestScore { bestScore = correctAnswers }

        let averageAccuracy = (Double(totalCorrectAnswers) / Double(totalGamesPlayed * 10)) * 100
        let statsMessage = """
        \(result.text)
        Количество сыгранных квизов: \(totalGamesPlayed)
        Лучший результат: \(bestScore)/10
        Средняя точность: \(Int(averageAccuracy))%
        """

        let alert = UIAlertController(
            title: result.title,
            message: statsMessage,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            self.showNextQuestion()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить данные. Попробуйте снова.",
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.showNextQuestion()
        }
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
}
