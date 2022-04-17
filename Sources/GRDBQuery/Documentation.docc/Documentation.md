# ``GRDBQuery``

The SwiftUI companion for GRDB

## Overview

GRDBQuery provides the `@Query` property wrapper, that lets your SwiftUI views automatically update their content when the database changes.

```swift
import GRDBQuery
import SwiftUI

/// A view that displays an always up-to-date list of players in the database.
struct PlayerList: View {
    @Query(AllPlayers())
    var players: [Player]
    
    var body: some View {
        List(players) { player in
            Text(player.name)
        }
    }
}
```

## Topics

### Guides

- <doc:GettingStarted>
- <doc:QueryableParameters>

### The @Query property wrapper

- ``Query``

### Feeding @Query with database content

- ``Queryable``
