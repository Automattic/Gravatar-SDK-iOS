import XCTest
@testable import Gravatar

final class CancellableDataTaskTests: XCTestCase {
    func testTaskIdentifierIsAlwaysEqual() throws {
        let cancellableTask = Task {}

        XCTAssertEqual(cancellableTask.taskIdentifier, cancellableTask.taskIdentifier)
        XCTAssertEqual(cancellableTask.taskIdentifier, cancellableTask.taskIdentifier)
        XCTAssertEqual(cancellableTask.taskIdentifier, cancellableTask.taskIdentifier)
    }

    func testTasksIdentifiersAreDifferentForDifferentTasks() throws {
        XCTAssertNotEqual(Task {}.taskIdentifier, Task {}.taskIdentifier)
    }
}
