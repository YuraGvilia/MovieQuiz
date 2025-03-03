//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 01.03.2025.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let storage: UserDefaults = .standard

    // Используем enum для ключей, чтобы не ошибиться в названиях
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
    }
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            // Если нет сохранённой даты, берем текущую дату
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get { storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }
    
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0 }
        let totalQuestions = gamesCount * 10  // предположим, что в каждой игре 10 вопросов
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        // Увеличиваем число сыгранных игр и правильных ответов
        gamesCount += 1
        correctAnswers += count
        
        // Сравниваем текущую игру с сохранённым рекордом
        let currentBestGame = bestGame
        let currentAccuracy = Double(count) / Double(amount)
        let bestAccuracy: Double = currentBestGame.total > 0 ?
            (Double(currentBestGame.correct) / Double(currentBestGame.total)) : 0
        
        if currentAccuracy > bestAccuracy {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
}
