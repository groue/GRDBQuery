import GRDBQuery
import Players
import SwiftUI

// MARK: - Give SwiftUI access to the player repository

// Define a new environment key that grants access to a `PlayerRepository`.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.
private struct PlayerRepositoryKey: EnvironmentKey {
    /// The default appDatabase is an empty in-memory repository.
    static let defaultValue = PlayerRepository.empty()
}

extension EnvironmentValues {
    var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

// MARK: - @Query convenience

// Convenience `Query` initializers for requests that feed
// from `PlayerRepository`.
//
// ```swift
// struct MyView {
//      // Without convenience initializer: verbose declaration.
//      @Query(MyRequest(), in: \.playerRepository) var myValue
//
//      // With convenience initializer: implicit database context.
//      @Query(MyRequest()) var myValue
// }
//
// private MyRequest: Queryable {
//     func publisher(in playerRepository: PlayerRepository) -> ... { }
// }
// ```
//
// When a request has no parameter, use `init(_ request: Request)`. When
// a request has some varying parameters, pick the initializer that fits the
// runtime behavior needed by your application, as described in
// <https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/queryableparameters>.
extension Query where Request.DatabaseContext == PlayerRepository {
    /// Creates a `Query`, given an initial `Queryable` request that
    /// feeds from `PlayerRepository`.
    init(_ request: Request) {
        self.init(request, in: \.playerRepository)
    }

    /// Creates a `Query`, given a SwiftUI binding to a `Queryable`
    /// request that feeds from `PlayerRepository`.
    init(_ request: Binding<Request>) {
        self.init(request, in: \.playerRepository)
    }

    /// Creates a `Query`, given a `Queryable` request that feeds
    /// from `PlayerRepository`.
    init(constant request: Request) {
        self.init(constant:request, in: \.playerRepository)
    }
}
