//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yura Gvilia on 10.03.2025.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
}

final class AlertPresenter {
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showResultAlert(title: String,
                         message: String,
                         buttonText: String,
                         action: (() -> Void)? = nil) {
        guard let delegate = delegate else {
            print("⚠ Ошибка: AlertPresenterDelegate = nil, алерт не будет показан!")
            return
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(title: buttonText, style: .default) { _ in
            action?()
        }
        alert.addAction(alertAction)
        
        delegate.presentAlert(alert)
    }
}
