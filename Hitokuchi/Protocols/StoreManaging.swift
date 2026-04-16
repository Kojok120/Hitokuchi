import Foundation
import StoreKit

/// ストア管理プロトコル
protocol StoreManaging {
    var purchasedProductIDs: Set<String> { get async }
    func loadProducts() async
    func purchase(_ product: Product) async throws -> StoreKit.Transaction
    func restorePurchases() async throws
}

enum StoreError: Error {
    case userCancelled
    case pending
    case unknown
    case verificationFailed

    @MainActor
    var localizedMessage: String {
        switch self {
        case .userCancelled: return L("store.error.userCancelled")
        case .pending: return L("store.error.pending")
        case .unknown: return L("store.error.unknown")
        case .verificationFailed: return L("store.error.verificationFailed")
        }
    }
}
