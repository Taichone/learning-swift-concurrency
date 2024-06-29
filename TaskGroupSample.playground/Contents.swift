import Foundation

// Main function
func performTasks() async -> Int {
    await withTaskGroup(of: Int.self) { group in
        group.addTask {
            print("Level 1 - Task 1 started")
            let result = await withTaskGroup(of: Int.self) { childGroup in
                childGroup.addTask {
                    print("Level 2 - Task 1.1 started")
                    let result = await withTaskGroup(of: Int.self) { grandchildGroup in
                        grandchildGroup.addTask {
                            let sleepNanoseconds: UInt64 = 8000000
                            print("Level 3 - Task 1.1.1 started and sleeping \(sleepNanoseconds)")
                            try? await Task.sleep(nanoseconds: sleepNanoseconds)
                            print("Level 3 - Task 1.1.1 completed")
                            return 10
                        }
                        grandchildGroup.addTask {
                            let sleepNanoseconds: UInt64 = 3000000
                            print("Level 3 - Task 1.1.2 started and sleeping \(sleepNanoseconds)")
                            try? await Task.sleep(nanoseconds: sleepNanoseconds)
                            print("Level 3 - Task 1.1.2 completed")
                            return 20
                        }

                        var sum = 0
                        for await value in grandchildGroup {
                            sum += value
                        }
                        return sum
                    }
                    print("Level 2 - Task 1.1 completed with result \(result)")
                    return result
                }
                childGroup.addTask {
                    let sleepNanoseconds: UInt64 = 1000000
                    print("Level 2 - Task 1.2 started and sleeping \(sleepNanoseconds)")
                    try? await Task.sleep(nanoseconds: sleepNanoseconds)
                    print("Level 2 - Task 1.2 completed")
                    return 30
                }

                var sum = 0
                for await value in childGroup {
                    sum += value
                }
                return sum
            }
            print("Level 1 - Task 1 completed with result \(result)")
            return result
        }

        group.addTask {
            let sleepNanoseconds: UInt64 = 0
            print("Level 1 - Task 2 started and sleeping \(sleepNanoseconds)")
            try? await Task.sleep(nanoseconds: sleepNanoseconds)
            print("Level 1 - Task 2 completed")
            return 40
        }

        var total = 0
        for await value in group {
            total += value
        }
        print("All tasks completed with total result \(total)")
        return total
    }
}

Task {
    let result = await performTasks()
    print("Final result: \(result)")
}
