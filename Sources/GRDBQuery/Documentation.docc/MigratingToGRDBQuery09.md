# Migrating To GRDBQuery 0.9

GRDBQuery 0.9 streamlines the definition of the queryable types that feed the `@Query` property wrapper.

## Overview

GRDBQuery 0.9 makes it even more convenient to feed SwiftUI views from a database with the `@Query` property wrappers.

- ✨ New: the ``DatabaseContext`` type and the ``SwiftUI/EnvironmentValues/databaseContext`` environment key provides a unified way to read, write, and observe a database from SwiftUI views.
- ✨ New: convenience protocols ``ValueObservationQueryable`` and ``FetchQueryable`` make it easier than ever to observe the database or perform a single fetch.

Breaking changes:

- @MainActor in views
- TODO
