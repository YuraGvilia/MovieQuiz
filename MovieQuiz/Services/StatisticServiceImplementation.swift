//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 03.03.2025.
//

import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    // MARK: - Ключи UserDefaults
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
    }
    
    // MARK: - Свойства из протокола
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0 }
        // Предположим, что в каждой игре 10 вопросов
        let totalQuestions = gamesCount * 10
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    // MARK: - Локальное хранение правильных ответов
    private var correctAnswers: Int {
        get { storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }
    
    // MARK: - Метод протокола для записи результатов
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        
        // Сравниваем текущую игру с сохранённым рекордом
        let currentBestGame = bestGame
        let currentAccuracy = Double(count) / Double(amount)
        
        let bestAccuracy = currentBestGame.total > 0
            ? Double(currentBestGame.correct) / Double(currentBestGame.total)
            : 0
        
        if currentAccuracy > bestAccuracy {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
}
