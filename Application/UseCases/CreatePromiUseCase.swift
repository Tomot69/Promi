import Foundation

struct CreatePromiUseCase: UseCase {
    typealias Input = AppTypes.CreatePromiInput
    typealias Output = AppTypes.CreatePromiOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
