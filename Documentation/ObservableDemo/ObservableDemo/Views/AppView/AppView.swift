import GRDBQuery
import SwiftUI

/// The main application view
struct AppView: View {
    @EnvironmentState private var viewModel: AppViewModel
    
    init() {
        _viewModel = EnvironmentState {
            AppViewModel(playerRepository: $0.playerRepository)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let player = viewModel.player {
                    PlayerView(player: player, editAction: viewModel.editPlayer)
                        .padding(.vertical)
                    
                    Spacer()
                    populatedFooter()
                } else {
                    PlayerView(player: .placeholder)
                        .padding(.vertical)
                        .redacted(reason: .placeholder)
                    
                    Spacer()
                    emptyFooter()
                }
            }
            .padding(.horizontal)
            .sheet(item: $viewModel.editedPlayer) { editedPlayer in
                PlayerEditionView(id: editedPlayer.id)
            }
            .navigationTitle("MVVM Demo")
        }
    }
    
    private func emptyFooter() -> some View {
        VStack {
            Text("The demo application observes the database and displays information about the player.")
                .informationStyle()
            
            CreatePlayerButton("Create a Player")
        }
        .informationBox()
    }
    
    private func populatedFooter() -> some View {
        VStack(spacing: 10) {
            Text("What if another application component deletes the player at the most unexpected moment?")
                .informationStyle()
            DeletePlayersButton("Delete Player")
            
            Spacer().frame(height: 10)
            Text("What if the player is deleted soon after the Edit button is hit?")
                .informationStyle()
            DeletePlayersButton("Delete After Editing", after: {
                viewModel.editPlayer()
            })
            
            Spacer().frame(height: 10)
            Text("What if the player is deleted right before the Edit button is hit?")
                .informationStyle()
            DeletePlayersButton("Delete Before Editing", before: {
                viewModel.editPlayer()
            })
        }
        .informationBox()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView().environment(\.playerRepository, .empty())
            .previewDisplayName("Database Initially Empty")
        AppView().environment(\.playerRepository, .populated())
            .previewDisplayName("Database Initially Populated")
    }
}
