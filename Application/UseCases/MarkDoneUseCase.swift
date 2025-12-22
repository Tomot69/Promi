import Foundation

struct MarkDoneUseCase: UseCase {
    typealias Input = AppTypes.MarkDoneInput
    typealias Output = AppTypes.MarkDoneOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
