import Foundation

struct AddCommentUseCase: UseCase {
    typealias Input = AppTypes.AddCommentInput
    typealias Output = AppTypes.AddCommentOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
