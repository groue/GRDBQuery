//
//  ContentView.swift
//  QueryTests
//
//  Created by Gwendal Roué on 17/05/2022.
//

import SwiftUI

struct ContentView: View {
    @State var request = Request(first: 1, second: 1)
    @State var id = 0
    @State var queryObservationEnabled = true
    
    var body: some View {
        VStack {
            Button("Change First") {
                request.first = 5
            }
            
            Button("Send Test Notification") {
                NotificationCenter.default.post(name: .test, object: nil)
            }
            
            Button("Change ID") {
                id += 1
            }
            
            Button("Toggle Query Observation") {
                queryObservationEnabled.toggle()
            }
            
            VStack {
                // Default request
                ValueView(accessibilityIdentifier: "default")
                ValueView(initialRequest: request, accessibilityIdentifier: "initial")
                ValueView(constantRequest: request, accessibilityIdentifier: "constant")
                ValueView($request, accessibilityIdentifier: "binding")
            }
            .id(id)
        }
        .environment(\.queryObservationEnabled, queryObservationEnabled)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
