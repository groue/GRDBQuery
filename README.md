# GRDBQuery

**Latest release**: May 1, 2022 • [version 0.3.0](https://github.com/groue/GRDBQuery/tree/0.3.0) • [CHANGELOG](CHANGELOG.md)

**Requirements**: iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ &bull; Swift 5.5+ / Xcode 13+

---

This package provides the `@Query` property wrapper, that lets your SwiftUI views automatically update their content when the database changes.

```swift
import GRDBQuery
import SwiftUI

/// A view that displays an always up-to-date list of players in the database.
struct PlayerList: View {
    @Query(PlayerRequest())
    var players: [Player]
    
    var body: some View {
        List(players) { player in
            Text(player.name)
        }
    }
}
```

`@Query` is for [GRDB] what [`@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest) is for Core Data. Although `@Query` does not depend on GRDB, it was designed with GRDB in mind.

## Why @Query?

**`@Query` solves a tricky SwiftUI challenge.** It makes sure SwiftUI views are *immediately* rendered with the database content you expect.

For example, when you display a `List` that animates its changes, you do not want to see an animation for the *initial* state of the list, or to prevent this undesired animation with extra code.

You also want your SwiftUI previews to display the expected values *without having to run them*.

Techniques based on [`onAppear(perform:)`](https://developer.apple.com/documentation/swiftui/view/onappear(perform:)), [`onReceive(_:perform)`](https://developer.apple.com/documentation/swiftui/view/onreceive(_:perform:)) and similar methods suffer from this "double-rendering" problem and its side effects. By contrast, `@Query` has you fully covered.

## Documentation

Learn how to use `@Query` in the **[Documentation]**, or jump straight to the **[Getting Started]** guide.

Check out the **[demo app]**, and the **[GRDB demo apps]** for various examples of `@Query` uses.

## Thanks

🙌 `@Query` was vastly inspired from [Core Data and SwiftUI](https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/) by [@davedelong](https://github.com/davedelong), with [a critical improvement](https://github.com/groue/GRDB.swift/pull/955) contributed by [@steipete](https://github.com/steipete). Many thanks to both of you!


[GRDB]: http://github.com/groue/GRDB.swift
[GRDB demo apps]: https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps
[Documentation]: https://groue.github.io/GRDBQuery/0.3/documentation/grdbquery/
[Getting Started]: https://groue.github.io/GRDBQuery/0.3/documentation/grdbquery/gettingstarted
[demo app]: Documentation/QueryDemo
