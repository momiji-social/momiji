import CoreTransferable
import GroupActivities

struct MomijiActivity: GroupActivity, Transferable {
    var metadata: GroupActivityMetadata = {
        var metadata = GroupActivityMetadata()
        metadata.title = "Momiji"
        metadata.type = .generic
        return metadata
    }()
}
