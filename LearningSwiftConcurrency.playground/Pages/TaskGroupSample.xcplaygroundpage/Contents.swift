import Foundation

/// TaskGroup の Task は並列的に全て開始されること
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
                            return Int(sleepNanoseconds)
                        }
                        grandchildGroup.addTask {
                            let sleepNanoseconds: UInt64 = 3000000
                            print("Level 3 - Task 1.1.2 started and sleeping \(sleepNanoseconds)")
                            try? await Task.sleep(nanoseconds: sleepNanoseconds)
                            print("Level 3 - Task 1.1.2 completed")
                            return Int(sleepNanoseconds)
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
                    return Int(sleepNanoseconds)
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
            return Int(sleepNanoseconds)
        }

        var total = 0
        for await value in group {
            total += value
        }
        print("All tasks completed with total result \(total)")
        return total
    }
}

/// .next() メソッドでは、addTask の順に関係なく、return された順に値が返されることを確認
func learningTaskGroupResultNext() async -> String {
    await withTaskGroup(of: Int.self) { group in
        group.addTask {
            let time = 5000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }
        group.addTask {
            let time = 1000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }
        group.addTask {
            let time = 3000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }

        print("gettingFirstResult")
        guard let firstResult = await group.next() else {
            group.cancelAll()
            return "error"
        }

        print("gettingSecondResult")
        guard let secondResult = await group.next() else {
            group.cancelAll()
            return "error"
        }

        print("gettingThirdResult")
        guard let thirdResult = await group.next() else {
            group.cancelAll()
            return "error"
        }

        print(firstResult)
        print(secondResult)
        print(thirdResult)

        return "success"
    }
}

/// for await in メソッドでは、addTask の順に関係なく、return された順に値が返されることを確認
func learningTaskGroupResultForAwaitIn() async -> String {
    await withTaskGroup(of: Int.self) { group in
        group.addTask {
            let time = 5000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }
        group.addTask {
            let time = 1000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }
        group.addTask {
            let time = 3000000000
            try? await Task.sleep(nanoseconds: UInt64(time))
            print("return \(time)")
            return time
        }

        print("for await in 開始")
        for await taskResult in group {
            print(taskResult)
        }

        return "success"
    }
}

Task {
    await print("performTasks() result: \(performTasks())")
    await print("learningTaskGroupResultNext() result: \(learningTaskGroupResultNext())")
    await print("learningTaskGroupResultForAwaitIn() result: \(learningTaskGroupResultForAwaitIn())")
}
