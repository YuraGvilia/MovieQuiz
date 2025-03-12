//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 09.03.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get set }
    var bestGame: GameResult { get set }
    
    func store(correct count: Int, total amount: Int)
}
