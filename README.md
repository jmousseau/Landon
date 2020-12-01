# Landon

Encode ARKit anchor geometries to the [Draco](https://github.com/google/draco)
and [OBJ](http://paulbourke.net/dataformats/obj/) file formats. Below is a
sample [`ARMeshAnchor`](https://apple.co/3c0G74T) encoding.

```swift
import Landon

// Gather all the mesh anchors.
let meshAnchors = session.currentFrame?.anchors.compactMap({ anchor in
    anchor as? ARMeshAnchor
})

// Encode the mesh anchors to the Draco file format.
let result = DracoEncoder.encode(meshAnchors: meshAnchors)
assert(result.status.code == .OK, "Encoding failed!")

// Encode the mesh anchors to the OBJ file format.
let result = OBJEncoder.encode(meshAnchors: meshAnchors)
assert(result != nil, "Encoding failed!")
```