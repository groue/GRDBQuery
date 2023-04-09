# Documentation

This directory contains two demo apps. Open DemoApps.xcworkspace in Xcode for a convenient access to both of them.

- [QueryDemo](QueryDemo) uses the [`@Query`](https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/gettingstarted) property wrapper.
- [MVVMDemo](MVVMDemo) uses the [`@EnvironmentStateObject`](https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/environmentstateobject) property wrapper as a support for the [MVVM](https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/mvvm) architecture, using the SwiftUI environment for dependency injection.
- Both apps share the [Players](Players) package, which wraps a database that contains "players".
