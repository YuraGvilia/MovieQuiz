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
    
    /// **Тест завершения игры: проверяем, что алерт появился**
    func testGameFinish() {
        sleep(2)

        for _ in 1...10 {
            let noButton = app.buttons["NoButton"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "No button did not appear in time")
            noButton.tap()
            sleep(1)
        }

        // Ждём появления алерта
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Game results alert did not appear")
    }

    /// **Тест закрытия алерта и начала новой игры**
    func testAlertDismiss() {
        sleep(2)

        for _ in 1...10 {
            let noButton = app.buttons["NoButton"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "No button did not appear in time")
            noButton.tap()
            sleep(1)
        }

        // Проверяем, появится ли алерт
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Game results alert did not appear")

        // Ждём, чтобы убедиться, что алерт действительно видим
        sleep(1)

        // Нажимаем кнопку "Сыграть ещё раз"
        let alertButton = alert.buttons.firstMatch
        XCTAssertTrue(alertButton.waitForExistence(timeout: 5), "Alert button did not appear in time")
        alertButton.tap()

        sleep(2)

        XCTAssertFalse(alert.exists, "Game results alert did not dismiss")
    }
}
