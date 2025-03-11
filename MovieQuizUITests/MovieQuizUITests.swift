import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Ждём, пока приложение загрузится
        let exists = app.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "Приложение не запустилось в заданное время!")
    }
    
    override func tearDownWithError() throws {
        if app != nil {
            app.terminate()
            app = nil
        }
        try super.tearDownWithError()
    }
    
    /// Тест кнопки "Да": постер меняется
    func testYesButtonChangesPoster() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster не появился вовремя")
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let yesButton = app.buttons["YesButton"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5), "YesButton не появился вовремя")
        yesButton.tap()
        
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Постер не изменился после нажатия 'Да'!")
    }
    
    /// Тест кнопки "Нет": постер меняется
    func testNoButtonChangesPoster() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster не появился вовремя")
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let noButton = app.buttons["NoButton"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5), "NoButton не появился вовремя")
        noButton.tap()
        
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Постер не изменился после нажатия 'Нет'!")
    }
    
    /// Тест завершения игры: проверяем, что алерт появился (заголовок, кнопка)
    func testGameFinish() {
        sleep(2)
        
        for _ in 1...10 {
            let noButton = app.buttons["NoButton"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "NoButton не появился вовремя")
            noButton.tap()
            sleep(1)
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Алерт с результатами не появился!")
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Неверный заголовок алерта")
        
        let alertButton = alert.buttons.firstMatch
        XCTAssertTrue(alertButton.exists, "Кнопка в алерте не найдена")
        XCTAssertEqual(alertButton.label, "Сыграть ещё раз", "Неверный текст кнопки алерта")
    }
    
    /// Тест закрытия алерта и начала новой игры
    func testAlertDismiss() {
        sleep(2)
        
        // Делаем 10 нажатий
        for _ in 1...10 {
            let noButton = app.buttons["NoButton"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "NoButton не появился вовремя")
            noButton.tap()
            sleep(1)
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Алерт с результатами не появился!")
        
        let alertButton = alert.buttons.firstMatch
        XCTAssertTrue(alertButton.waitForExistence(timeout: 5), "Кнопка в алерте не найдена")
        alertButton.tap()
        
        sleep(2)
        
        XCTAssertFalse(alert.exists, "Алерт не скрылся после нажатия кнопки!")
        
        // Проверяем, что счетчик стал "1/10"
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label не появился")
        XCTAssertEqual(indexLabel.label, "1/10", "Счетчик не сбросился до 1/10!")
    }
}
