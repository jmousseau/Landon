# Landon

Landon can encode ARKit's [`ARMeshAnchor`](https://apple.co/3c0G74T) to the [Draco file
format](https://github.com/google/draco).

```swift
import Landon

// Gather all the mesh anchors.
let meshAnchors = session.currentFrame?.anchors.compactMap({ anchor in
    anchor as? ARMeshAnchor
})

// Encode the mesh anchors.
let result = DracoEncoder.encode(meshAnchors: meshAnchors)
assert(result.status.code == .OK, "Encoding failed!")
```