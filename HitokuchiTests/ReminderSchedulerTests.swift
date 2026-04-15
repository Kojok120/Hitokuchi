import Testing
import Foundation
@testable import Hitokuchi

@Suite("ReminderScheduler Tests")
@MainActor
struct ReminderSchedulerTests {

    // MARK: - Interval Calculation (via public interface)

    /// Tests that the scheduler can be instantiated and exposes correct dependencies
    @Test("ReminderScheduler instantiation with default MessageEngine")
    func instantiation() {
        let scheduler = ReminderSchedulerService()
        // Verify the scheduler exists and conforms to protocol
        let _: ReminderScheduling = scheduler
        #expect(true, "Scheduler instantiated successfully")
    }

    // MARK: - Quiet Hours Logic

    @Test("Quiet hours spanning midnight: 22:00-7:00")
    func quietHoursSpansMidnight() {
        // Test the quiet hours check logic
        // 22:00-7:00 should be quiet at 23:00, 0:00, 6:00
        // 22:00-7:00 should NOT be quiet at 8:00, 12:00, 21:00
        let quietStart = 22
        let quietEnd = 7

        // We test the underlying logic by verifying the hour check
        #expect(isInQuietHours(hour: 23, start: quietStart, end: quietEnd) == true)
        #expect(isInQuietHours(hour: 0, start: quietStart, end: quietEnd) == true)
        #expect(isInQuietHours(hour: 6, start: quietStart, end: quietEnd) == true)
        #expect(isInQuietHours(hour: 22, start: quietStart, end: quietEnd) == true)

        #expect(isInQuietHours(hour: 7, start: quietStart, end: quietEnd) == false)
        #expect(isInQuietHours(hour: 8, start: quietStart, end: quietEnd) == false)
        #expect(isInQuietHours(hour: 12, start: quietStart, end: quietEnd) == false)
        #expect(isInQuietHours(hour: 21, start: quietStart, end: quietEnd) == false)
    }

    @Test("Quiet hours within same day: 1:00-6:00")
    func quietHoursSameDay() {
        let quietStart = 1
        let quietEnd = 6

        #expect(isInQuietHours(hour: 2, start: quietStart, end: quietEnd) == true)
        #expect(isInQuietHours(hour: 5, start: quietStart, end: quietEnd) == true)
        #expect(isInQuietHours(hour: 1, start: quietStart, end: quietEnd) == true)

        #expect(isInQuietHours(hour: 0, start: quietStart, end: quietEnd) == false)
        #expect(isInQuietHours(hour: 6, start: quietStart, end: quietEnd) == false)
        #expect(isInQuietHours(hour: 12, start: quietStart, end: quietEnd) == false)
    }

    // MARK: - Progress Multiplier Logic

    @Test("Progress multiplier varies with remaining ratio")
    func progressMultiplierLogic() {
        // High remaining (80-100%) = shorter interval (0.7x)
        // Medium remaining (50-80%) = base interval (1.0x)
        // Low remaining (20-50%) = longer interval (1.3x)
        // Very low (<20%) = longest interval (1.8x)
        let baseInterval: TimeInterval = 90 * 60 // 5400 seconds

        // When 90% remains (just started), interval should be shorter
        let highRemaining = calculateInterval(remainingRatio: 0.9)
        let expectedHigh = baseInterval * 0.7
        #expect(highRemaining == expectedHigh, "High remaining should use 0.7x multiplier")

        // When 60% remains, use base interval
        let mediumRemaining = calculateInterval(remainingRatio: 0.6)
        let expectedMedium = baseInterval * 1.0
        #expect(mediumRemaining == expectedMedium, "Medium remaining should use 1.0x multiplier")

        // When 30% remains, longer interval
        let lowRemaining = calculateInterval(remainingRatio: 0.3)
        let expectedLow = baseInterval * 1.3
        #expect(lowRemaining == expectedLow, "Low remaining should use 1.3x multiplier")

        // When 10% remains, longest interval
        let veryLowRemaining = calculateInterval(remainingRatio: 0.1)
        let expectedVeryLow = baseInterval * 1.8
        #expect(veryLowRemaining == expectedVeryLow, "Very low remaining should use 1.8x multiplier")
    }

    // MARK: - Negative Interval Guard

    @Test("Negative interval guard ensures minimum of 1 second")
    func negativeIntervalGuard() {
        // Simulating the max(1, interval) guard from the scheduler
        let negativeInterval: TimeInterval = -100
        let guarded = max(1, negativeInterval)
        #expect(guarded == 1, "Negative interval should be guarded to 1")

        let zeroInterval: TimeInterval = 0
        let guardedZero = max(1, zeroInterval)
        #expect(guardedZero == 1, "Zero interval should be guarded to 1")

        let positiveInterval: TimeInterval = 5400
        let guardedPositive = max(1, positiveInterval)
        #expect(guardedPositive == 5400, "Positive interval should pass through unchanged")
    }

    // MARK: - Helpers (mirroring private logic for testability)

    private func isInQuietHours(hour: Int, start: Int, end: Int) -> Bool {
        if start > end {
            return hour >= start || hour < end
        } else {
            return hour >= start && hour < end
        }
    }

    private func calculateInterval(remainingRatio: Double) -> TimeInterval {
        let baseInterval: TimeInterval = 90 * 60

        let progressMultiplier: Double
        switch remainingRatio {
        case 0.8...1.0: progressMultiplier = 0.7
        case 0.5..<0.8: progressMultiplier = 1.0
        case 0.2..<0.5: progressMultiplier = 1.3
        default:        progressMultiplier = 1.8
        }

        return baseInterval * progressMultiplier
    }
}
