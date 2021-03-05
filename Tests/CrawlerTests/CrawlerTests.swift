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
                throw CrawlerError.error(message: "can't get string or beginning index of \"-\"")
            }
            let removedPreviousStr = wholeStr[index...].replacingOccurrences(of: "= ", with: "")
            guard let endIndex = removedPreviousStr.firstIndex(of: "p") else {
                throw CrawlerError.error(message: "can't get string or end index of \"p\"")
            }
            let valStr = removedPreviousStr[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            return valStr
        } action: { valStr in
            guard let hkdToPoundVal = Double(valStr) else {
                throw CrawlerError.error(message: "can't cast to double")
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

        // do {
        //     repeat {
        //         try crawler.run()
        //     } while crawler.isRunning
        // } catch let CrawlerError.error(error) {
        //     print("Error: \(error)")
        // } catch CrawlerError.noData {
        //     print("No Data.")
        // } catch {
        //     print("error: \(error)")
        // }

        repeat {
            crawler.run { error in
                switch error {
                case let CrawlerError.error(message: msg):
                    print(msg)
                case CrawlerError.noData:
                    print("No Data")
                case let lowerLevelError:
                    print("error: \(lowerLevelError)")
                }
            }
        } while crawler.isRunning
        sleep(5)
    }

    func testExample1() {
        let err1: Swift.Error = CrawlerError.noData
        let err2: Swift.Error = CrawlerError.error(message: "some error")
        let err3: Swift.Error = Error.network

        [err1, err2, err3].forEach {
            // switch $0 {
            // case let CrawlerError.error(message: msg):
            //     print(msg)
            // case CrawlerError.noData:
            //     print("No data")
            // case let lowerLevelError:
            //     print("error: \(lowerLevelError)")
            // }
            switch $0 {
            case let crawlerError as CrawlerError:
                switch crawlerError {
                case .noData:
                    print("No Data")
                case let .error(message: errMsg):
                    print("Error Message: \(errMsg)")
                }
            case let lowerLevelError:
                print("other error: \(lowerLevelError)")
            }
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
