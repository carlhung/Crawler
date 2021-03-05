import Foundation
#if os(Linux)
    import FoundationNetworking
#endif

// import SwiftSoup

@frozen
public enum CrawlerError: Swift.Error {
    case noData
    case error(message: String)
}

public final class Crawler {
    public var url: URL
    public var handler: (Data) throws -> String
    public var action: (String) throws -> Void
    public var waiting: UInt32
    private var data: Result<Data, Error>?

    // private var data: Result<Data, Swift.Error>?
    public private(set) var isRunning: Bool = false

    /// `waiting` while calling `run`, it checks if the data is back in each time of seconds of `waiting`.
    public init(url: URL, waiting: UInt32 = 1, handler: @escaping (Data) throws -> String, action: @escaping (String) throws -> Void) {
        self.url = url
        self.handler = handler
        self.action = action
        self.waiting = waiting
    }

    public func run(errorAction: @escaping (Error) -> Void) {
        if !isRunning {
            isRunning = true
            URLSession.shared.dataTask(with: url) { [unowned self] data, _, error in
                defer {
                    self.isRunning = false
                }
                guard error == nil else {
                    errorAction(error!)
                    return
                }
                guard let data = data else {
                    errorAction(CrawlerError.noData)
                    return
                }
                do {
                    try action(handler(data))
                } catch let err {
                    errorAction(err)
                }
            }
            .resume()
        }
    }

    public func run() throws {
        if !isRunning, data == nil {
            isRunning = true
            URLSession.shared.dataTask(with: url) { [unowned self] data, _, error in
                defer {
                    self.isRunning = false
                }
                guard error == nil else {
                    self.data = Result.failure(error!)
                    return
                }
                guard let data = data else {
                    self.data = Result.failure(CrawlerError.noData)
                    return
                }
                self.data = Result.success(data)
            }
            .resume()
            while data == nil {
                sleep(waiting)
            }
            switch data {
            case let .failure(error):
                throw error
            case let .success(resultData):
                try action(handler(resultData))
            default:
                break
            }
            data = nil
        }
    }
}
