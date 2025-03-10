import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    /// Показывает текущий шаг викторины
    func show(quiz step: QuizStepViewModel)

    /// Показывает итоговый экран с результатами
    func show(quiz result: QuizResultsViewModel)

    /// Подсвечивает рамку изображения в зависимости от правильности ответа
    func highlightImageBorder(isCorrectAnswer: Bool)

    /// Показывает индикатор загрузки
    func showLoadingIndicator()

    /// Скрывает индикатор загрузки
    func hideLoadingIndicator()

    /// Показывает сообщение об ошибке сети
    func showNetworkError(message: String)
}
