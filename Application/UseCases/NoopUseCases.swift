import Foundation

struct NoopCreatePromi: UseCase {
    struct Input: Equatable {
        let titleRaw: String
    }

    struct Output: Equatable {
        let createdId: UUID
    }

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        // No-op: P0-B05 interdit toute mutation/persistance.
        return .failure(.persistence(.writeFailed))
    }
}

