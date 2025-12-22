import Foundation

struct EditPromiUseCase: UseCase {
    typealias Input = AppTypes.EditPromiInput
    typealias Output = AppTypes.EditPromiOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
