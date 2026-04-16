import Foundation
import StoreKit

/// StoreKit 2管理サービス。8商品の非消費型IAP。
@MainActor @Observable
final class StoreManagerService {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    @ObservationIgnored
    private var transactionListener: Task<Void, Never>?

    static let allProductIDs: Set<String> = [
        "hitokuchi.bundle.all",
        "hitokuchi.theme.sakura",
        "hitokuchi.theme.ocean",
        "hitokuchi.theme.forest",
        "hitokuchi.theme.sunset",
        "hitokuchi.theme.night",
        "hitokuchi.voice.kansai",
        "hitokuchi.voice.kyoto"
    ]

    init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public

    var hasBundleAll: Bool {
        purchasedProductIDs.contains("hitokuchi.bundle.all")
    }

    func isThemeUnlocked(_ theme: AppTheme) -> Bool {
        guard let productID = theme.productID else { return true } // Default is always unlocked
        return hasBundleAll || purchasedProductIDs.contains(productID)
    }

    func isVoicePackUnlocked(_ tone: MessageTone) -> Bool {
        guard let productID = tone.productID else { return true } // Default is always unlocked
        return hasBundleAll || purchasedProductIDs.contains(productID)
    }

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: Self.allProductIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return transaction
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await self?.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}
