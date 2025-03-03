import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The_Godfather", text: "Рейтинг этого фильма\nбольше чем 8?", correctAnswer: true),
        QuizQuestion(image: "The_Dark_Knight", text: "Рейтинг этого фильма\nбольше чем 9?", correctAnswer: true),
        QuizQuestion(image: "Kill_Bill", text: "Рейтинг этого фильма\nбольше чем 7?", correctAnswer: true),
        QuizQuestion(image: "The_Avengers", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма\nбольше чем 7?", correctAnswer: true),
        QuizQuestion(image: "The_Green_Knight", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The_Ice_Age_Adventures", text: "Рейтинг этого фильма\nбольше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма\nбольше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма\nбольше чем 6?", correctAnswer: false)
    ]

    weak var delegate: QuestionFactoryDelegate?
    private var askedQuestionsIndexes: Set<Int> = [] // ✅ Храним уже показанные вопросы

    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }

    func requestNextQuestion() {
        print("🔄 Запрос нового вопроса...")

        // ✅ Если уже задали все вопросы, сбрасываем историю
        if askedQuestionsIndexes.count == questions.count {
            print("♻️ Все вопросы были заданы! Начинаем заново.")
            askedQuestionsIndexes.removeAll()
        }

        // ✅ Генерируем индекс, пока он не будет новым
        var newIndex: Int
        repeat {
            newIndex = (0..<questions.count).randomElement()!
        } while askedQuestionsIndexes.contains(newIndex)

        askedQuestionsIndexes.insert(newIndex) // Добавляем в список использованных
        let question = questions[newIndex]

        print("✅ Новый вопрос выбран: \(question.text)")
        delegate?.didReceiveNextQuestion(question: question)
    }
}
