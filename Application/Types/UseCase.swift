import Foundation

protocol UseCase {
    associatedtype Input
    associatedtype Output: Equatable

    func execute(_ input: Input) async -> UseCaseResult<Output>
}

