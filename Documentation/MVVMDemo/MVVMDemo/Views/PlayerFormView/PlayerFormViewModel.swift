import Combine
import GRDB
import Players

/// The view model for ``PlayerFormView``.
final class PlayerFormViewModel: ObservableObject {
    private let playerRepository: PlayerRepository
    
    /// The player to display.
    @Published private(set) var player: Player
    
    init(playerRepository: PlayerRepository, editedPlayer player: Player) {
        self.playerRepository = playerRepository
        self.player = player
    }
    
    /// Increments the player score.
    func incrementScore() {
        updatePlayer { $0.score += 10 }
    }
    
    /// Decrements the player score.
    func decrementScore() {
        updatePlayer { $0.score = max(0, $0.score - 10) }
    }
    
    private func updatePlayer(_ transform: (inout Player) -> Void) {
        do {
            var updatedPlayer = player
            transform(&updatedPlayer)
            try playerRepository.update(updatedPlayer)
            
            // Only update view if update was successful in the database
            player = updatedPlayer
        } catch RecordError.recordNotFound {
            // Oops, player does not exist.
            // Ignore this error: `PlayerEditionView` will dismiss.
        } catch {
            // Ignore other errors.
        }
    }
}
