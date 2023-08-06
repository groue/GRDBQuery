import SwiftUI
import GRDBQuery

@main
struct ObservableDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TestView()
//            AppView()
//                // Use the on-disk repository in the application
//                .environment(\.playerRepository, .shared)
        }
    }
}

@Observable
class Model {
    var name: String
    var score: Int
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}

struct TestView: View {
    @EnvironmentState var wrapper: Model
    
    init() {
        _wrapper = EnvironmentState { _ in Model(name: "Paul", score: 0) }
    }
    
    var body: some View {
        Self._printChanges()
        return VStack {
            NameView(name: $wrapper.name)
            ScoreView(score: $wrapper.score)
        }
    }
}

struct NameView: View {
    @Binding var name: String
    
    var body: some View {
        Self._printChanges()
        return VStack {
            Text(name)
            Button("Change Name") {
                name = UUID().uuidString
            }
        }
    }
}

struct ScoreView: View {
    @Binding var score: Int
    
    var body: some View {
        Self._printChanges()
        return VStack {
            Text("\(score)")
            Button("Change Score") {
                score += 1
            }
        }
    }
}
