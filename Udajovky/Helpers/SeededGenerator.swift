import Foundation
import GameKit
import GameplayKit

struct SeededGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        let next1 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        let next2 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        return next1 ^ (next2 << 32)
    }

    init(seed: UInt64) {
        gkrandom = GKMersenneTwisterRandomSource(seed: seed)
    }

    private let gkrandom: GKRandom
}
