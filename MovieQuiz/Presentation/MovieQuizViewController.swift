import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - UI Элементы
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!

    // MARK: - Данные
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?

    // MARK: - Статистика
    // Объявляем переменную типа протокола StatisticService
    private var statisticService: StatisticService!
    
    // MARK: - Alert Presenter
    private var alertPresenter: ResultAlertPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuestionFactory()
        // Инициализируем statisticService с помощью класса StatisticServiceImplementation
        statisticService = StatisticServiceImplementation()
        alertPresenter = ResultAlertPresenter(viewController: self)
        questionFactory?.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        print("📩 Вопрос получен от фабрики: \(question?.text ?? "nil")")
        guard let question = question else {
            print("❌ Ошибка: Получен nil-вопрос")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            print("🔄 Обновление UI с новым вопросом...")
            self?.show(quiz: viewModel)
            self?.view.isUserInteractionEnabled = true // ✅ Разблокируем UI
        }
    }

    // MARK: - UI Настройки
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Внедрение фабрики
    private func setupQuestionFactory() {
        let questionFactory = QuestionFactory(delegate: self)
        self.questionFactory = questionFactory
    }

    // MARK: - Логика игры
    private func showNextQuestion() {
        print("🔄 Запрос нового вопроса, индекс: \(currentQuestionIndex)")
        view.isUserInteractionEnabled = true // ✅ Разблокируем UI
        questionFactory?.requestNextQuestion()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(systemName: "photo")!,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        print("🖼 UI обновляется с новым вопросом: \(step.question)")
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // Сброс цвета рамки для изображения, чтобы не оставался предыдущий цвет
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        print("✅ Нажата кнопка 'Да'")
        checkAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        print("❌ Нажата кнопка 'Нет'")
        checkAnswer(false)
    }

    private func checkAnswer(_ answer: Bool) {
        self.view.isUserInteractionEnabled = false
        guard let currentQuestion = currentQuestion else {
            print("⚠️ Ошибка: currentQuestion = nil!")
            return
        }
        print("🎯 Проверка ответа. Ожидаемый: \(currentQuestion.correctAnswer), полученный: \(answer)")
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }

    private func showAnswerResult(isCorrect: Bool) {
        print("📊 Ответ \(isCorrect ? "верный ✅" : "неверный ❌")")
        if isCorrect { correctAnswers += 1 }
        imageView.layer.borderColor = (isCorrect ? UIColor(hex: "#60C28E") : UIColor(hex: "#F56B6C"))?.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            print("➡️ Переход к следующему вопросу...")
            if self.currentQuestionIndex < self.questionsAmount - 1 {
                self.currentQuestionIndex += 1
                self.showNextQuestion()
            } else {
                self.showFinalResults()
            }
        }
    }

    // MARK: - Отображение результатов
    private func showFinalResults() {
        print("🏁 Квиз завершён! Итог: \(correctAnswers)/\(questionsAmount)")
        
        // Сохраняем результаты игры через statisticService
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        // Формируем текст статистики
        let currentGameText = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let gamesCountText = "Количество сыгранных игр: \(statisticService.gamesCount)"
        let bestGame = statisticService.bestGame
        let bestGameText = "Лучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let statsMessage = """
        \(currentGameText)
        \(gamesCountText)
        \(bestGameText)
        \(accuracyText)
        """
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: statsMessage,
            buttonText: "Сыграть ещё раз"
        )
        
        // Используем ResultAlertPresenter для отображения алерта
        alertPresenter.showAlert(with: viewModel) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showNextQuestion()
        }
    }
}
