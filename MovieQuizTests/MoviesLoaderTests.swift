import XCTest
@testable import MovieQuiz  // даёт доступ к MoviesLoader, NetworkClient и т.д.

/// Заглушка (stub) для протокола NetworkRouting.
/// Она может либо возвращать "успешные" данные (expectedResponse),
/// либо имитировать ошибку, если emulateError == true.
struct StubNetworkClient: NetworkRouting {
    let emulateError: Bool
    
    func fetch(url: URL, completion handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            // Эмулируем ошибку
            handler(.failure(TestError.test))
        } else {
            // Возвращаем "правильный" JSON
            handler(.success(expectedResponse))
        }
    }
    
    enum TestError: Error {
        case test
    }
    
    /// Тестовый JSON, который декодируется в MostPopularMovies.
    /// Здесь у нас 2 фильма, значит ожидаем в тесте movies.count == 2.
    private var expectedResponse: Data {
        """
        {
           "items": [
              {
                 "crew": "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                 "fullTitle": "Prey (2022)",
                 "id": "tt11866324",
                 "imDbRating": "7.2",
                 "imDbRatingCount": "93332",
                 "image": "https://m.media-amazon.com/images/Prey.jpg",
                 "rank": "1",
                 "rankUpDown": "+23",
                 "title": "Prey",
                 "year": "2022"
              },
              {
                 "crew": "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                 "fullTitle": "The Gray Man (2022)",
                 "id": "tt1649418",
                 "imDbRating": "6.5",
                 "imDbRatingCount": "132890",
                 "image": "https://m.media-amazon.com/images/GrayMan.jpg",
                 "rank": "2",
                 "rankUpDown": "-1",
                 "title": "The Gray Man",
                 "year": "2022"
              }
           ],
           "errorMessage": ""
        }
        """.data(using: .utf8) ?? Data()
    }
}

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given: заглушка не эмулирует ошибку
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        // Передаём заглушку в MoviesLoader
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // Создаём ожидание для асинхронного кода
        let expectation = expectation(description: "Loading expectation")
        
        // When: вызываем loadMovies
        loader.loadMovies { result in
            // Then: проверяем результат
            switch result {
            case .success(let movies):
                // movies — это [MostPopularMovie], ожидаем 2 элемента
                XCTAssertEqual(movies.count, 2, "Должно быть 2 фильма")
                expectation.fulfill()
            case .failure:
                XCTFail("Не ожидали ошибку, но получили её")
            }
        }
        
        // Ждём до 1 секунды, пока не выполнится expectation
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given: заглушка ЭМУЛИРУЕТ ошибку
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        let expectation = expectation(description: "Loading expectation")
        
        // When
        loader.loadMovies { result in
            // Then
            switch result {
            case .success:
                XCTFail("Ожидали ошибку, но получили успех")
            case .failure(let error):
                // Проверяем, что ошибка действительно пришла
                XCTAssertNotNil(error, "Ошибка должна быть не nil")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
