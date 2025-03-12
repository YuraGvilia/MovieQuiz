import Foundation

/// Протокол, описывающий базовый сетевой функционал
protocol NetworkRouting {
    func fetch(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

/// Реальная реализация протокола, ходит в сеть через URLSession
struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case invalidStatusCode
    }
    
    func fetch(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Если есть ошибка сети — сразу возвращаем её
            if let error = error {
                completion(.failure(error))
                return
            }
            // Проверяем код ответа (должен быть 2xx)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.invalidStatusCode))
                return
            }
            // Проверяем, что data не nil
            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Нет данных от сервера"
                ])
                completion(.failure(noDataError))
                return
            }
            // Успех — возвращаем Data
            completion(.success(data))
        }
        
        task.resume()
    }
}
