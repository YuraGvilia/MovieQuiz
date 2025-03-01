//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 01.03.2025.
//

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
