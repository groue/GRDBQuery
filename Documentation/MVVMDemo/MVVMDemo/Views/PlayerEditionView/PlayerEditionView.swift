import GRDBQuery
import SwiftUI

/// The sheet for player edition.
///
/// In this demo app, this view don't want to remain on screen
/// whenever the edited player no longer exists in the database.
struct PlayerEditionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentStateObject private var viewModel: PlayerEditionViewModel
    
    init(id: Int64) {
        _viewModel = EnvironmentStateObject {
            PlayerEditionViewModel(playerRepository: $0.playerRepository, id: id)
        }
    }
    
    var body: some View {
        NavigationView {
            if let player = viewModel.player {
                VStack {
                    PlayerFormView(player: player)
                    Spacer()
                    VStack(spacing: 10) {
                        Text("What if another application component deletes the player at the most unexpected moment?")
                            .informationStyle()
                        DeletePlayersButton("Delete Player")
                    }
                    .informationBox()
                }
                .padding(.horizontal)
                .navigationTitle(player.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { dismiss() }
                    }
                }
            } else {
                PlayerNotFoundView()
            }
        }
        .alert(
            "Ooops, player is gone.",
            isPresented: $viewModel.gonePlayerAlertPresented) {
                Button("Dismiss") { dismiss() }
            }
    }
}

// MARK: - Previews

#Preview("Existing player") {
    PlayerEditionView(id: 1)
        .playerRepository(.populated(playerId: 1))
}

#Preview("Missing player") {
    PlayerEditionView(id: -1)
        .playerRepository(.empty())
}
