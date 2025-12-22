import Foundation

enum UseCaseResult<Output>: Equatable where Output: Equatable {
    case success(Output)
    case failure(PromiError)
}
