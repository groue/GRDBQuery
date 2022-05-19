import GRDB
import GRDBQuery
import SwiftUI

/// The view that edits a player
struct PlayerFormView: View {
    @EnvironmentStateObject private var viewModel: PlayerFormViewModel
    
    init(player: Player) {
        _viewModel = EnvironmentStateObject {
            PlayerFormViewModel(
                appDatabase: $0.appDatabase,
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
        PlayerFormView(player: .makeRandom())
            .padding()
    }
}
