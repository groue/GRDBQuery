import Combine
import Dispatch
import Foundation

/// A Combine scheduler that executes its work on the main actor as soon
/// as possible.
///
/// If `MainActorScheduler.shared.schedule` is invoked from the main actor
/// then the unit of work will be performed immediately. This is in contrast
/// to `DispatchQueue.main.schedule`, which will always incur a hop
/// before executing.
///
/// This scheduler can be useful for situations where you need work executed
/// as quickly as possible on the main actor, and for which a hop would
/// be problematic.
struct MainActorScheduler: Scheduler {
    typealias SchedulerOptions = Never
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    
    /// The shared instance of the UI scheduler.
    ///
    /// You cannot create instances of the UI scheduler yourself. Use only the shared instance.
    static let shared = Self()
    
    var now: SchedulerTimeType { DispatchQueue.main.now }
    var minimumTolerance: SchedulerTimeType.Stride { DispatchQueue.main.minimumTolerance }
    
    func schedule(options: SchedulerOptions? = nil, _ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.schedule(action)
        }
    }
    
    func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions? = nil,
        _ action: @escaping () -> Void
    ) {
        DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: nil, action)
    }
    
    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions? = nil,
        _ action: @escaping () -> Void
    ) -> any Cancellable {
        DispatchQueue.main.schedule(
            after: date, interval: interval, tolerance: tolerance, options: nil, action
        )
    }
    
    private init() { }
}
