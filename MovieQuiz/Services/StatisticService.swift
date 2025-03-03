//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 01.03.2025.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }

    func store(correct count: Int, total amount: Int)
}
