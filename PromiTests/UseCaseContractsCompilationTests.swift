import XCTest
@testable import Promi

final class UseCaseContractsCompilationTests: XCTestCase {

    func test_canInstantiateAllUseCases() {
        _ = CreatePromiUseCase()
        _ = EditPromiUseCase()
        _ = DeletePromiUseCase()
        _ = MarkDoneUseCase()
        _ = ReopenPromiUseCase()
        _ = AddBravoUseCase()
        _ = AddCommentUseCase()
    }
}
