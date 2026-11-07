import Combine
import GRDB
import GRDBQuery
import Testing

struct FetchQueryableTests {
    @Test @MainActor
    func value_is_fetched_immediately() throws {
        struct Request: FetchQueryable {
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex(false)
        _ = publisher.sink { completion in
            if case .failure = completion { Issue.record() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        #expect(valueMutex.withLock { $0 })
    }
    
    @Test @MainActor
    func value_is_not_fetched_immediately_and_received_on_main_actor_with_async_option() async throws {
        struct Request: FetchQueryable {
            static let queryableOptions = QueryableOptions.async
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex(false)
        var cancellable: AnyCancellable?
        await withCheckedContinuation { continuation in
            cancellable = publisher.sink { completion in
                if case .failure = completion { Issue.record() }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    valueMutex.withLock { $0 = value }
                    continuation.resume()
                }
            }
            #expect(!valueMutex.withLock { $0 })
        }
        withExtendedLifetime(cancellable) { }
        #expect(valueMutex.withLock { $0 })
    }
    
    @Test @MainActor
    func custom_context() throws {
        struct DatabaseManager: TopLevelDatabaseReader {
            var reader: any DatabaseReader
        }
        struct Request: FetchQueryable {
            typealias Context = DatabaseManager
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let manager = DatabaseManager(reader: dbQueue)
        let publisher = request.publisher(in: manager)
        
        let valueMutex = Mutex(false)
        _ = publisher.sink { completion in
            if case .failure = completion { Issue.record() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        #expect(valueMutex.withLock { $0 })
    }
}
