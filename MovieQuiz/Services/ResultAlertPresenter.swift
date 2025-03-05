import UIKit

final class ResultAlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Метод для показа результата квиза
    func showAlert(with viewModel: QuizResultsViewModel, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.text, preferredStyle: .alert)
        let action = UIAlertAction(title: viewModel.buttonText, style: .default) { _ in
            completion()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    // Новый метод для показа ошибки сети с использованием модели AlertModel
    func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        
        vc.present(alert, animated: true)
    }
}
