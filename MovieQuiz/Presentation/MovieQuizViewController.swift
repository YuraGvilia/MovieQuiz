// Автор: Yura Gvilia

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - UI Элементы (IBOutlet)
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!

    // MARK: - Приватные переменные (данные)
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?

    // MARK: - Сервисы
    private var statisticService: StatisticService!
    
    // MARK: - Alert Presenter (для показа алертов)
    private var alertPresenter: ResultAlertPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        alertPresenter = ResultAlertPresenter(viewController: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
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
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.questionFactory?.requestNextQuestion()
            print("✅ Данные успешно загружены с сервера")
        }
    }
    
    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkError(message: error.localizedDescription)
            print("❌ Ошибка загрузки данных: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Приватные методы UI и логики
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showNextQuestion() {
        print("🔄 Запрос нового вопроса, индекс: \(currentQuestionIndex)")
        view.isUserInteractionEnabled = true
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(systemName: "photo")!,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        print("🖼 UI обновляется с новым вопросом: \(step.question)")
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Методы для Activity Indicator
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: - Обработка ошибок сети (добавлена повторная загрузка)
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator() // Показываем индикатор загрузки
            self.questionFactory?.loadData() // Пробуем загрузить фильмы ещё раз
        }
        alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - Действия пользователя (IBAction)
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        print("✅ Нажата кнопка 'Да'")
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        print("❌ Нажата кнопка 'Нет'")
        checkAnswer(false)
    }
    
    // MARK: - Приватные методы проверки и отображения ответов
    private func checkAnswer(_ answer: Bool) {
        view.isUserInteractionEnabled = false
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
        
        let correctColor = UIColor(named: "QuizBorderColorCorrect")
        let incorrectColor = UIColor(named: "QuizBorderColorIncorrect")
        imageView.layer.borderColor = (isCorrect ? correctColor : incorrectColor)?.cgColor
        
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
    
    private func showFinalResults() {
        print("🏁 Квиз завершён! Итог: \(correctAnswers)/\(questionsAmount)")
        statisticService.store(correct: correctAnswers, total: questionsAmount)

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

        alertPresenter.showAlert(with: viewModel) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0 // Сброс индекса перед новой игрой
            self.correctAnswers = 0
            self.showNextQuestion()
        }
    }
    
    // MARK: - Переопределяем стиль статус-бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
