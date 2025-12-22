import Foundation

struct ReopenPromiUseCase: UseCase {
    typealias Input = AppTypes.ReopenPromiInput
    typealias Output = AppTypes.ReopenPromiOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
