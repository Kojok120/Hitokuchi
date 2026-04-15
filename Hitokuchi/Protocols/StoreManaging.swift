import Foundation
import StoreKit

/// ストア管理プロトコル
protocol StoreManaging {
    var purchasedProductIDs: Set<String> { get async }
    func loadProducts() async
    func purchase(_ product: Product) async throws -> StoreKit.Transaction
    func restorePurchases() async throws
}

enum StoreError: Error, LocalizedError {
    case userCancelled
    case pending
    case unknown
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .userCancelled: return "購入がキャンセルされました"
        case .pending: return "購入が保留中です"
        case .unknown: return "不明なエラーが発生しました"
        case .verificationFailed: return "購入の検証に失敗しました"
        }
    }
}
