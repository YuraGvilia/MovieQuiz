//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 28.02.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
