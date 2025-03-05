import Foundation

/// Модель вопроса для квиза
struct QuizQuestion {
    let image: Data       
    let text: String
    let correctAnswer: Bool
}
