import Foundation

enum GpsWidth: Character {
    case north = "N"
    case south = "S"
}

enum GpsLength: Character {
    case east = "E"
    case west = "W"
}

struct GpsPossition {
//    let width: GpsWidth
//    let length: GpsLength
    // TODO: isthis really needed ? lat/ long is defined on both - possitive and negative intervals, so it  is abvious
    var lattitude: Int
    let longitude: Int
    // FIXME: double

    init(
        //        width: GpsWidth,
//        length: GpsLength,
        lattitude: Int,
        longitude: Int
    ) {
//        self.width = width
//        self.length = length
        self.lattitude = lattitude
        self.longitude = longitude
    }

    static func == (lhs: GpsPossition, rhs: GpsPossition) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.lattitude == rhs.lattitude
    }
}
