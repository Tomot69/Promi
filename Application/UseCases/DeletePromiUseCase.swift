import Foundation

struct DeletePromiUseCase: UseCase {
    typealias Input = AppTypes.DeletePromiInput
    typealias Output = AppTypes.DeletePromiOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
