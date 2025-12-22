import Foundation

struct AddBravoUseCase: UseCase {
    typealias Input = AppTypes.AddBravoInput
    typealias Output = AppTypes.AddBravoOutput

    func execute(_ input: Input) async -> UseCaseResult<Output> {
        return .failure(.persistence(.writeFailed))
    }
}
