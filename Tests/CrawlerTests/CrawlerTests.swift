@testable import Crawler
import SwiftSoup
import XCTest

let poundUrl = URL(string: "https://www.google.com/search?q=hkd+to+pound&rlz=1C5CHFA_enHK927HK927&oq=hkd+to+pun&aqs=chrome.1.69i57j0i10l6.4072j0j7&sourceid=chrome&ie=UTF-8")

final class CrawlerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(Crawler().text, "Hello, World!")
        guard let url = poundUrl else {
            XCTAssert(false)
            return
        }
        let crawler = Crawler(url: url) { data in
            let html = String(decoding: data, as: UTF8.self)

            let doc = try SwiftSoup.parse(html)
            let elms: Elements = try doc.select("div")
            var str: String?
            for elm in elms where try elm.text().contains("pound") {
                try str = elm.text()
                break
            }
            guard let wholeStr = str, let index = wholeStr.firstIndex(of: "=") else {
                throw CrawlerError.handlerError(message: "can't get string or beginning index of \"-\"")
            }
            let removedPreviousStr = wholeStr[index...].replacingOccurrences(of: "= ", with: "")
            guard let endIndex = removedPreviousStr.firstIndex(of: "p") else {
                throw CrawlerError.handlerError(message: "can't get string or end index of \"p\"")
            }
            let valStr = removedPreviousStr[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            return valStr
        } action: { valStr in
            guard let hkdToPoundVal = Double(valStr) else {
                throw CrawlerError.actionError(message: "can't cast to double")
            }
            // let dateStr = String(Date().description.split(separator: " ")[0].split(separator: "-")[2])
            // let msg = "$1HKD to GBP: $\(hkdToPoundVal)\n$1GBP to HKD: $\(1 / hkdToPoundVal)"
            // if dateStr != date {
            //     date = String(dateStr)
            //     // message(msg)
            //     // return
            // }
            // if hkdToPoundVal > 0.1 {
            //     // message("It is time to exchange.\n\(msg)")
            // }
            let msg = "$1HKD to GBP: $\(hkdToPoundVal)\n$1GBP to HKD: $\(1 / hkdToPoundVal)"
            print(msg)
        }

        do {
            repeat {
                try crawler.run()
            } while crawler.isRunning
        } catch let CrawlerError.actionError(error) {
            print("Action Error: \(error)")
        } catch let CrawlerError.handlerError(error) {
            print("Handler Error: \(error)")
        } catch CrawlerError.noData {
            print("No Data.")
        } catch {
            print("error: \(error)")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
