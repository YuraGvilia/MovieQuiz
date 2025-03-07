import Foundation

protocol QuestionFactoryProtocol {
    /// Начать асинхронную загрузку данных (фильмов) с сервера
    func loadData()
    
    /// Запросить следующий вопрос (уже после загрузки)
    func requestNextQuestion()
}
