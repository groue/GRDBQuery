import SwiftUI

/// A button that creates players in the database
struct CreateButton: View {
    @Environment(\.appDatabase) private var appDatabase
    private var titleKey: LocalizedStringKey
    
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
    }
    
    var body: some View {
        Button {
            try! appDatabase.insert(Player.makeRandom())
        } label: {
            Label(titleKey, systemImage: "plus")
        }
    }
}

/// A button that deletes players in the database
struct DeleteButton: View {
    private enum Mode {
        case deleteAfter
        case deleteBefore
    }
    
    @Environment(\.appDatabase) private var appDatabase
    private var titleKey: LocalizedStringKey
    private var action: (() -> Void)?
    private var mode: Mode
    
    /// Creates a button that simply deletes players.
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
        self.mode = .deleteBefore
    }
    
    /// Creates a button that deletes players soon after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        after action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.action = action
        self.mode = .deleteAfter
    }
    
    /// Creates a button that deletes players immediately after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        before action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.action = action
        self.mode = .deleteBefore
    }
    
    var body: some View {
        Button {
            switch mode {
            case .deleteAfter:
                action?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    _ = try! appDatabase.deleteAllPlayer()
                }
                
            case .deleteBefore:
                _ = try! appDatabase.deleteAllPlayer()
                action?()
            }
        } label: {
            Label(titleKey, systemImage: "trash")
        }
    }
}

import GRDB
import GRDBQuery // For tracking the player count in the preview

struct DatabaseButtons_Previews: PreviewProvider {
    struct PlayerCountRequest: Queryable {
        static var defaultValue: Int { 0 }
        
        func publisher(in appDatabase: AppDatabase) -> DatabasePublishers.Value<Int> {
            ValueObservation
                .tracking(Player.fetchCount)
                .publisher(in: appDatabase.databaseReader, scheduling: .immediate)
        }
    }
    
    struct Preview: View {
        @Query(PlayerCountRequest())
        var playerCount: Int
        
        var body: some View {
            VStack {
                Text("Number of players: \(playerCount)")
                CreateButton("Create Player")
                DeleteButton("Delete Players")
            }
            .informationBox()
            .padding()
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
