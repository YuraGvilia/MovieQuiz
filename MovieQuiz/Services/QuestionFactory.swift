import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    if movies.isEmpty {
                        let emptyError = NSError(domain: "", code: -3, userInfo: [
                            NSLocalizedDescriptionKey: "Список фильмов пуст. Попробуйте позже."
                        ])
                        self.delegate?.didFailToLoadData(with: emptyError)
                        return
                    }
                    self.movies = movies
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Если фильмов нет, отправим nil
            guard let movie = self.movies.randomElement() else {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            // Генерируем случайный рейтинг (5...9) и случайный тип вопроса (больше/меньше)
            let randomThreshold = Float.random(in: 5...9)
            let rating = Float(movie.rating) ?? 0
            let isGreater = Bool.random()
            
            let text = isGreater
                ? "Рейтинг этого фильма больше, чем \(Int(randomThreshold))?"
                : "Рейтинг этого фильма меньше, чем \(Int(randomThreshold))?"
            
            let correctAnswer = isGreater ? (rating > randomThreshold) : (rating < randomThreshold)
            
            // Пытаемся загрузить постер
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                // Ошибка загрузки постера — сообщим о ней
                DispatchQueue.main.async {
                    let customError = NSError(
                        domain: "",
                        code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки постера фильма."]
                    )
                    self.delegate?.didFailToLoadData(with: customError)
                }
                return
            }
            
            // Формируем вопрос
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            // Возвращаемся в главный поток
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
