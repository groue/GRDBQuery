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
        updateScore { $0 += 10 }
    }
    
    func decrementScore() {
        updateScore { $0 = max(0, $0 - 10) }
    }
    
    private func updateScore(_ transform: (inout Int) -> Void) {
        do {
            transform(&player.score)
            try appDatabase.update(player)
        } catch PersistenceError.recordNotFound {
            // Oops, player does not exist.
            // Ignore this error: `PlayerEditionView` will dismiss.
            //
            // You can comment out this specific handling of
            // `PersistenceError.recordNotFound`, run the preview, change the
            // score, and see what happens.
        } catch {
            fatalError("\(error)")
        }
    }
}
