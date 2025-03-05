import Foundation

/// Простой сетевой клиент, который умеет загружать `Data` по URL
struct NetworkClient {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 1) Проверяем, не пришла ли сразу ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // 2) Проверяем HTTP-код ответа
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // 3) Проверяем, что data не nil
            guard let data = data else {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // 4) Всё ок — возвращаем data
            handler(.success(data))
        }
        
        task.resume()
    }
}
