import Foundation

/// Протокол, описывающий функциональность загрузки фильмов
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<[MostPopularMovie], Error>) -> Void)
}

/// Реализация загрузчика фильмов
struct MoviesLoader: MoviesLoading {
    /// Сюда мы внедряем зависимость (DI) через протокол NetworkRouting.
    /// По умолчанию — реальный NetworkClient, но в тестах можем подменить.
    private let networkClient: NetworkRouting
    
    /// Позволяем вызвать MoviesLoader() без параметров
    /// или MoviesLoader(networkClient: другойКлиент) в тестах.
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func loadMovies(handler: @escaping (Result<[MostPopularMovie], Error>) -> Void) {
        // Допустим, URL хранится в некоем Constants. Если у тебя нет такого файла — просто пропиши строку напрямую.
        guard let url = URL(string: Constants.apiTopMoviesURL) else {
            let urlError = NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Некорректный адрес сервера."
            ])
            handler(.failure(urlError))
            return
        }
        
        // Делаем запрос
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    // Пытаемся декодировать в MostPopularMovies
                    let decodedResponse = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    // Если сервер вернул сообщение об ошибке
                    if let errorMsg = decodedResponse.errorMessage, !errorMsg.isEmpty {
                        let customError = NSError(domain: "", code: -2, userInfo: [
                            NSLocalizedDescriptionKey: errorMsg
                        ])
                        handler(.failure(customError))
                        return
                    }
                    
                    // Если список фильмов пуст
                    if decodedResponse.items.isEmpty {
                        let emptyError = NSError(domain: "", code: -3, userInfo: [
                            NSLocalizedDescriptionKey: "Список фильмов пуст. Попробуйте позже."
                        ])
                        handler(.failure(emptyError))
                        return
                    }
                    
                    // Всё хорошо — передаём массив фильмов
                    handler(.success(decodedResponse.items))
                } catch {
                    // Ошибка декодирования JSON
                    handler(.failure(error))
                }
                
            case .failure(let error):
                // Ошибка сети или HTTP-кода
                handler(.failure(error))
            }
        }
    }
}
