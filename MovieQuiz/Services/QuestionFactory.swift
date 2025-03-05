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
        moviesLoader.loadMovies { [weak self] (result: Result<MostPopularMovies, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    /// Создаёт случайный вопрос о фильме
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            // Выбираем случайный фильм
            guard let movie = self.movies.randomElement() else { return }
            
            // Генерация случайного порога рейтинга (от 5 до 9)
            let randomThreshold = Float.random(in: 5...9)
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше, чем \(Int(randomThreshold))?"
            let correctAnswer = rating > randomThreshold
            
            // Загружаем изображение
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("⚠️ Ошибка загрузки изображения: \(error.localizedDescription)")
            }
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
