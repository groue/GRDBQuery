# Release Notes

## v0.11.0

Released on 2025/03/15

- **New**: adds QueryableOptions.assertNoFailure to treat errors as fatalError by [@ChristophKaser](https://github.com/ChristophKaser) in [#64](https://github.com/groue/GRDBQuery/pull/64)

## v0.10.1

Released on 2024/09/29

- **Fixed**: Have SPI build Swift 6 documentation

## v0.10.0

Released on 2024/09/28

- **Breaking Change**: Depend on GRDB 7.0.0-beta+ by [@groue](https://github.com/groue) in [#58]https://github.com/groue/GRDBQuery/pull/58)


## v0.9.0

Released on 2024/07/20

- **New** [#52](https://github.com/groue/GRDBQuery/pull/52): DatabaseContext, and convenience queryable protocols.

See the [Migrating To GRDBQuery 0.9](https://swiftpackageindex.com/groue/grdbquery/0.9.0/documentation/grdbquery/migratingtogrdbquery09) guide.

## v0.8.0

Released on 2023/12/01

- **New** [#49](https://github.com/groue/GRDBQuery/pull/49): Make Value an associated type of Queryable.

## v0.7.0

Released on 2023/03/25

- **New** [#41](https://github.com/groue/GRDBQuery/pull/41): Convenience `@Query` initializers for `Void` DatabaseContext
- **New** [#42](https://github.com/groue/GRDBQuery/pull/42): Demo apps access the database via a PlayerRepository package
- **Breaking Change** [#43](https://github.com/groue/GRDBQuery/pull/43): Bump minimum Swift version to 5.7

## v0.6.0

Released on 2023/02/24

- [#37](https://github.com/groue/GRDBQuery/pull/37): Bump OS dependencies

## v0.5.1

Released on 2022/10/08

- Prepare for documentation hosting on http://swiftpackageindex.com/

## v0.5.0

Released on 2022/09/04

- Fix Xcode 14 runtime warnings that read "Publishing changes from within view updates is not allowed, this will cause undefined behavior."

## v0.4.0

Released on 2022/05/20

- [#25](https://github.com/groue/GRDBQuery/pull/25) `@EnvironmentStateObject` and support for MVVM applications
- [#24](https://github.com/groue/GRDBQuery/pull/24) Tests

## v0.3.0

Released on 2022/05/01

- [#23](https://github.com/groue/GRDBQuery/pull/23) Request Observation Control
- Breaking Change: the `isAutoupdating` binding and `View.mirrorAppearanceState` methods have been replaced with [`QueryObservation`](https://groue.github.io/GRDBQuery/0.3/documentation/grdbquery/queryobservation).

## v0.2.0

Released on 2022/04/18

- [#18](https://github.com/groue/GRDBQuery/pull/18) Control @Query auto-updates
- [#17](https://github.com/groue/GRDBQuery/pull/17) Fine-Grained Query initializers

## v0.1.0

Released on 2021/11/25
