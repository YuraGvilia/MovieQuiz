//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 28.02.2025.
//

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
