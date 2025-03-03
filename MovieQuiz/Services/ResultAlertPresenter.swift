//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 01.03.2025.
//

import UIKit

final class ResultAlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(with viewModel: QuizResultsViewModel, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.text, preferredStyle: .alert)
        let action = UIAlertAction(title: viewModel.buttonText, style: .default) { _ in
            completion()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
