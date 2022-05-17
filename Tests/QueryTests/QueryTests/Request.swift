//
//  Request.swift
//  QueryTests
//
//  Created by Gwendal Roué on 17/05/2022.
//

import Combine
import Foundation
import GRDBQuery
import SwiftUI

private struct VoidKey: EnvironmentKey {
    static var defaultValue: Void { () }
}

extension EnvironmentValues {
    var void: Void {
        get { self[VoidKey.self] }
        set { self[VoidKey.self] = newValue }
    }
}

extension Notification.Name {
    static let test = Notification.Name("test")
}

struct Request: Queryable {
    static var defaultValue: Int { 0 }
    var first: Int
    var second: Int
    
    /// Publishes `n + (first * second)`, where `n` is the number of received
    /// "test" notifications.
    ///
    /// The first value `first * second` is published right on subscription.
    func publisher(in _: Void) -> AnyPublisher<Int, Never> {
        NotificationCenter.default
            .publisher(for: .test)
            .scan(0) { (n, _) in n + 1 }
            .prepend(0)
            .map { $0 + first * second }
            .eraseToAnyPublisher()
    }
}
