import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<[MostPopularMovie], Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func loadMovies(handler: @escaping (Result<[MostPopularMovie], Error>) -> Void) {
        guard let url = URL(string: Constants.apiTopMoviesURL) else {
            let urlError = NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Некорректный адрес сервера."
            ])
            handler(.failure(urlError))
            return
        }
        
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if let errorMsg = decodedResponse.errorMessage, !errorMsg.isEmpty {
                        handler(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                        return
                    }
                    
                    if decodedResponse.items.isEmpty {
                        handler(.failure(NSError(domain: "", code: -3, userInfo: [
                            NSLocalizedDescriptionKey: "Список фильмов пуст. Попробуйте позже."
                        ])))
                        return
                    }
                    
                    handler(.success(decodedResponse.items))
                } catch {
                    handler(.failure(error))
                }
                
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
