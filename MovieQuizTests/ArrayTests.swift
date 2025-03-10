import XCTest
@testable import MovieQuiz  // чтобы иметь доступ к коду из основного модуля

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given: создаём массив из 5 чисел
        let array = [1, 1, 2, 3, 5]
        
        // When: берём элемент по индексу 2
        let value = array[safe: 2]
        
        // Then: проверяем, что value не nil и равно 2
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given: тот же массив
        let array = [1, 1, 2, 3, 5]
        
        // When: пытаемся получить элемент по индексу 20
        let value = array[safe: 20]
        
        // Then: проверяем, что value nil
        XCTAssertNil(value)
    }
}
