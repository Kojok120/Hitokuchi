import Testing
@testable import Hitokuchi

@Suite("HydrationCalculator Tests")
struct HydrationCalculatorTests {

    let calculator = HydrationCalculatorService()

    // MARK: - Effective Water Calculation

    @Test("Water has coefficient 1.0, yields exact volume")
    func waterCoefficient() {
        let beverage = BeverageMaster(
            name: "水",
            category: .water,
            hydrationCoefficient: 1.0
        )
        let result = calculator.calculateEffectiveWater(beverage: beverage, amount: .mugCup)
        #expect(result == 250.0, "Water should yield 250ml for mug cup")
    }

    @Test("Tea with coefficient 0.99 reduces effective water")
    func teaCoefficient() {
        let beverage = BeverageMaster(
            name: "煎茶",
            category: .tea,
            hydrationCoefficient: 0.99
        )
        let result = calculator.calculateEffectiveWater(beverage: beverage, amount: .mugCup)
        let expected = 250.0 * 0.99
        #expect(abs(result - expected) < 0.01, "Tea should yield \(expected)ml, got \(result)")
    }

    @Test("Coffee with coefficient 0.97 reduces effective water")
    func coffeeCoefficient() {
        let beverage = BeverageMaster(
            name: "コーヒー",
            category: .coffee,
            hydrationCoefficient: 0.97
        )
        let result = calculator.calculateEffectiveWater(beverage: beverage, amount: .petBottleFull)
        let expected = 500.0 * 0.97
        #expect(abs(result - expected) < 0.01, "Coffee should yield \(expected)ml, got \(result)")
    }

    @Test("Soup with coefficient 0.90 reduces effective water")
    func soupCoefficient() {
        let beverage = BeverageMaster(
            name: "味噌汁",
            category: .soup,
            hydrationCoefficient: 0.90
        )
        let result = calculator.calculateEffectiveWater(beverage: beverage, amount: .owan)
        let expected = 180.0 * 0.90
        #expect(abs(result - expected) < 0.01, "Soup should yield \(expected)ml, got \(result)")
    }

    // MARK: - All Drink Amounts

    @Test("Effective water calculated for all drink amounts",
          arguments: DrinkAmount.allCases)
    func allDrinkAmounts(amount: DrinkAmount) {
        let beverage = BeverageMaster(
            name: "水",
            category: .water,
            hydrationCoefficient: 1.0
        )
        let result = calculator.calculateEffectiveWater(beverage: beverage, amount: amount)
        #expect(result == amount.volumeML, "Water (1.0 coefficient) should yield exact volume for \(amount)")
    }

    // MARK: - HydrationProgress

    @Test("HydrationProgress ratio calculation")
    func progressRatio() {
        let progress = HydrationProgress(totalML: 1000, goalML: 2000, logCount: 4)
        #expect(progress.ratio == 0.5)
        #expect(progress.percentage == 50.0)
        #expect(progress.isGoalAchieved == false)
        #expect(progress.remainingML == 1000)
    }

    @Test("HydrationProgress achieved when total >= goal")
    func progressAchieved() {
        let progress = HydrationProgress(totalML: 2000, goalML: 2000, logCount: 8)
        #expect(progress.ratio == 1.0)
        #expect(progress.isGoalAchieved == true)
        #expect(progress.remainingML == 0)
    }

    @Test("HydrationProgress exceeded returns zero remaining")
    func progressExceeded() {
        let progress = HydrationProgress(totalML: 2500, goalML: 2000, logCount: 10)
        #expect(progress.ratio == 1.25)
        #expect(progress.isGoalAchieved == true)
        #expect(progress.remainingML == 0)
    }

    @Test("HydrationProgress zero goal does not divide by zero")
    func progressZeroGoal() {
        let progress = HydrationProgress(totalML: 500, goalML: 0, logCount: 2)
        #expect(progress.ratio == 0)
        #expect(progress.percentage == 0)
    }

    // MARK: - ProgressStage

    @Test("ProgressStage mapping from percentage")
    func progressStageMapping() {
        #expect(ProgressStage.from(percentage: 0) == .notStarted)
        #expect(ProgressStage.from(percentage: 15) == .beginning)
        #expect(ProgressStage.from(percentage: 50) == .onTrack)
        #expect(ProgressStage.from(percentage: 85) == .almostDone)
        #expect(ProgressStage.from(percentage: 100) == .achieved)
        #expect(ProgressStage.from(percentage: 120) == .exceeded)
    }

    @Test("All progress stages are covered by from(percentage:)")
    func allStagesCovered() {
        let stages: [ProgressStage] = [
            .from(percentage: 0),
            .from(percentage: 10),
            .from(percentage: 40),
            .from(percentage: 75),
            .from(percentage: 100),
            .from(percentage: 110)
        ]
        #expect(stages.count == 6)
    }
}
