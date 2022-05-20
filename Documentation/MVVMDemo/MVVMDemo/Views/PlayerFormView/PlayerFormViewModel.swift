import Combine
import GRDB

final class PlayerFormViewModel: ObservableObject {
    private var appDatabase: AppDatabase
    @Published var player: Player

    init(appDatabase: AppDatabase, editedPlayer player: Player) {
        self.appDatabase = appDatabase
        self.player = player
    }
    
    func incrementScore() {
        updatePlayer { $0.score += 10 }
    }
    
    func decrementScore() {
        updatePlayer { $0.score = max(0, $0.score - 10) }
    }
    
    private func updatePlayer(_ transform: (inout Player) -> Void) {
        do {
            var updatedPlayer = player
            transform(&updatedPlayer)
            try appDatabase.update(updatedPlayer)
            
            // Only update view if update was succesfull in the database
            player = updatedPlayer
        } catch PersistenceError.recordNotFound {
            // Oops, player does not exist.
            // Ignore this error: `PlayerEditionView` will dismiss.
        } catch {
            fatalError("\(error)")
        }
    }
}
