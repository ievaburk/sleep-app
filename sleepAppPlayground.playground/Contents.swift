import CreateML
import Foundation

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/Ieva/Desktop/sleep-app/better-rest.json"))
let (trainingData, testingData) = data.randomSplit(by: 0.8)

let regressor = try MLRegressor(trainingData: trainingData, targetColumn: "actualSleep")

let evaluationMetrics = regressor.evaluation(on: testingData)
print(evaluationMetrics.rootMeanSquaredError)
print(evaluationMetrics.maximumError)

let metadata = MLModelMetadata(author: "Ieva Burk", shortDescription: "A model to predict optimal sleep times based on coffee consumed and sleep wanted", version: "1.0")

try regressor.write(to: URL(fileURLWithPath: "/Users/Ieva/Desktop/sleep-app/SleepCalculator.mlmodel"), metadata: metadata)
