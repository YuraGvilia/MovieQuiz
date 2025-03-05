import Foundation

/// Делегат, чтобы фабрика вопросов сообщала контроллеру о загрузке и готовых вопросах
protocol QuestionFactoryDelegate: AnyObject {
    /// Вызывается, когда фабрика успешно загрузила все данные (список фильмов)
    func didLoadDataFromServer()
    
    /// Вызывается, когда произошла ошибка при загрузке данных
    func didFailToLoadData(with error: Error)
    
    /// Вызывается, когда фабрика подготовила следующий вопрос
    func didReceiveNextQuestion(question: QuizQuestion?)
}
