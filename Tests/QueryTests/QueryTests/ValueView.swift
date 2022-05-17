//
//  ValueView.swift
//  QueryTests
//
//  Created by Gwendal Roué on 17/05/2022.
//

import GRDBQuery
import SwiftUI

struct ValueView: View {
    var accessibilityIdentifier: String
    @Query(Request(first: 2, second: 3), in: \.void) var value
    
    /// Default request
    init(accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    /// Initial request
    init(initialRequest request: Request, accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
        _value = Query(request, in: \.void)
    }
    
    /// Constant request
    init(constantRequest request: Request, accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
        _value = Query(constant: request, in: \.void)
    }
    
    /// Request binding
    init(_ request: Binding<Request>, accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
        _value = Query(request, in: \.void)
    }
    
    var body: some View {
        HStack {
            Text(verbatim: "\(value)")
                .accessibilityIdentifier("\(accessibilityIdentifier).value")
            
            Button("Change Request") {
                $value.request.wrappedValue.second = 7
            }
            .accessibilityIdentifier("\(accessibilityIdentifier).changeRequestButton")
            
            Button("Send Test Notification") {
                NotificationCenter.default.post(name: .test, object: nil)
            }
            .accessibilityIdentifier("\(accessibilityIdentifier).notificationButton")
        }
        .padding()
    }
}

struct ValueView_Previews: PreviewProvider {
    static var previews: some View {
        ValueView(accessibilityIdentifier: "ignored")
    }
}
