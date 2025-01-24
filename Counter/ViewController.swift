// Created by Yura Gvilia

import UIKit

final class ViewController: UIViewController {
    
    // UI элементы
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 200, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton = ViewController.createRoundButton(title: "+", color: .systemRed)
    private let minusButton = ViewController.createRoundButton(title: "-", color: .systemBlue)
    private let resetButton = ViewController.createRectButton(title: "↺", color: .systemGreen)
    
    private let historyTextView: UITextView = {
        let textView = UITextView()
        textView.text = "История изменений:"
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // Счётчик
    private var counterValue = 0 {
        didSet {
            counterLabel.text = "\(counterValue)"
            saveCounterValue()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCounterValue()
    }
    
    // Конфигурация интерфейса
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        view.addSubview(counterLabel)
        view.addSubview(plusButton)
        view.addSubview(minusButton)
        view.addSubview(resetButton)
        view.addSubview(historyTextView)
        
        plusButton.addTarget(self, action: #selector(incrementCounter), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decrementCounter), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetCounter), for: .touchUpInside)
        
        setupConstraints()
    }
    
    // Настройка ограничений (Auto Layout)
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Счётчик
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            
            // Кнопка "+"
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            plusButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            plusButton.widthAnchor.constraint(equalToConstant: 100),
            plusButton.heightAnchor.constraint(equalToConstant: 100),
            
            // Кнопка "-"
            minusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            minusButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            minusButton.widthAnchor.constraint(equalToConstant: 100),
            minusButton.heightAnchor.constraint(equalToConstant: 100),
            
            // Кнопка "↺" (Reset) ниже других кнопок
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 60),
            
            // История изменений
            historyTextView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 30),
            historyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // Действия для кнопок
    @objc private func incrementCounter() {
        counterValue += 1
        addHistoryEntry("значение изменено на +1")
    }
    
    @objc private func decrementCounter() {
        if counterValue > 0 {
            counterValue -= 1
            addHistoryEntry("значение изменено на -1")
        } else {
            addHistoryEntry("попытка уменьшить значение счётчика ниже 0")
        }
    }
    
    @objc private func resetCounter() {
        counterValue = 0
        addHistoryEntry("значение сброшено")
    }
    
    // Добавление записи в историю с датой
    private func addHistoryEntry(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ru_RU")
        let timestamp = formatter.string(from: Date())
        historyTextView.text.append("\n[\(timestamp)]: \(message)")
        
        // Автоскролл вниз
        let range = NSMakeRange(historyTextView.text.count - 1, 1)
        historyTextView.scrollRangeToVisible(range)
    }
    
    // Функции сохранения и загрузки значения счётчика
    private func saveCounterValue() {
        UserDefaults.standard.set(counterValue, forKey: "counterValue")
    }
    
    private func loadCounterValue() {
        counterValue = UserDefaults.standard.integer(forKey: "counterValue")
    }
    
    // Утилитный метод для создания круглых кнопок
    private static func createRoundButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 50
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Утилитный метод для создания прямоугольной кнопки сброса
    private static func createRectButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
