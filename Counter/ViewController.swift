//
//  Created by Yura Gvilia
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.boldSystemFont(ofSize: 250)
        label.textColor = .cyan
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        // Добавление неонового эффекта
        label.layer.shadowColor = UIColor.cyan.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowRadius = 20
        label.layer.shadowOpacity = 1.0

        return label
    }()
    
    private let mainButton: UIButton = {
        let button = UIButton(type: .system)

        // Увеличенная системная иконка "плюс"
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 150, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        
        button.setImage(largeImage, for: .normal)
        button.tintColor = .magenta
        button.translatesAutoresizingMaskIntoConstraints = false

        // Добавление тени для неонового эффекта
        button.layer.shadowColor = UIColor.magenta.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowRadius = 50
        button.layer.shadowOpacity = 1.0
        
        return button
    }()
    
    private var counterValue = 0
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupUI()
    }
    
    // Установка фона
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 10/255, green: 25/255, blue: 50/255, alpha: 1.0).cgColor,
            UIColor(red: 0/255, green: 10/255, blue: 30/255, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    // Настройка UI элементов
    private func setupUI() {
        view.addSubview(counterLabel)
        view.addSubview(mainButton)

        setupConstraints()
        
        // Добавляем действие для кнопки
        mainButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Лейбл: по центру экрана с отступом вверх
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            
            // Кнопка: центр и отступ снизу
            mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            mainButton.widthAnchor.constraint(equalToConstant: 150),  // Размер кнопки
            mainButton.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func didTapButton() {
        counterValue += 1
        UIView.transition(with: counterLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.counterLabel.text = "\(self.counterValue)"
        }, completion: nil)
        
        animateButton()
        playClickSound()
    }

    private func animateButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.mainButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.mainButton.layer.shadowRadius = 70
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.mainButton.transform = CGAffineTransform.identity
                self.mainButton.layer.shadowRadius = 50
            }
        }
    }

    private func playClickSound() {
        guard let soundURL = Bundle.main.url(forResource: "click", withExtension: "mp3") else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("Не удалось воспроизвести звук: \(error.localizedDescription)")
        }
    }
}
