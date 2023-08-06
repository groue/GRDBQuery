import GRDBQuery
import Players
import SwiftUI

/// The view that edits a player
struct PlayerFormView: View {
    @EnvironmentState private var viewModel: PlayerFormViewModel
    
    init(player: Player) {
        _viewModel = EnvironmentState {
            PlayerFormViewModel(
                playerRepository: $0.playerRepository,
                editedPlayer: player)
        }
    }
    
    var body: some View {
        Stepper(
            "Score: \(viewModel.player.score)",
            onIncrement: { viewModel.incrementScore() },
            onDecrement: { viewModel.decrementScore() })
    }
}

struct PlayerFormView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Player exists in the database") {
                PlayerFormView(player: .makeRandom(id: 1))
                    .environment(\.playerRepository, .populated(playerId: 1))
            }
            
            Section("Player does not exist in the database") {
                PlayerFormView(player: .makeRandom())
                    .environment(\.playerRepository, .empty())
            }
        }
    }
}
