MVVM Demo Application
=====================

<img align="right" src="https://github.com/groue/GRDBQuery/raw/main/Documentation/MVVMDemo/Screenshot.png" width="50%">

This demo application shows how the [`@EnvironmentStateObject`](https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/environmentstateobject) property wrapper helps an [MVVM](https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/mvvm) SwiftUI application access a database. Mainly:

- The [main view](MVVMDemo/Views/AppView/AppView.swift) of the app is kept up-to-date with the information stored in the database.
- [A sheet](MVVMDemo/Views/PlayerEditionView/PlayerEditionView.swift) makes sure it gets dismissed as soon as the value it needs no longer exists in the database.

It is also an opportunity to explore a few practices:

- _The database is the single source of truth._ All views feed from the database, and communicate through the database. This is not a general rule that fits all applications, but it fits well this demo app.
- _The application is robust against surprising database changes._ Surprises usually happen as your application evolves, is extended with new features, becomes more complex. In this demo application, all the purple buttons trigger scenarios that could happen in real life. How do we make the app robust in all those scenarios? 
- _The application accesses the database via the `Players` Swift Package.
