import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
}

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?

    // MARK: - Инициализация (теперь delegate всегда передается)
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }

    // MARK: - Метод показа алерта
    func showResultAlert(
        title: String,
        message: String,
        buttonText: String,
        action: (() -> Void)? = nil // Опциональный action
    ) {
        // Проверяем, существует ли делегат
        guard let delegate = delegate else {
            print("⚠ Ошибка: `AlertPresenterDelegate` = nil, алерт не будет показан!")
            return
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let alertAction = UIAlertAction(title: buttonText, style: .default) { _ in
            action?() // Вызываем action, если он передан
        }
        alert.addAction(alertAction)

        // Показываем алерт через делегата
        delegate.presentAlert(alert)
    }
}
