import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    // Метод сравнения рекордов по количеству правильных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
