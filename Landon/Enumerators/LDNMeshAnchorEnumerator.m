//
//  LDNMeshAnchorEnumerator.m
//  Landon
//
//  Created by Jack Mousseau on 12/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNMeshAnchorEnumerator.h"


/// A geometry enumerator which enumerates a set of mesh anchors.
@interface LDNMeshAnchorEnumerator ()

/// The set of mesh anchors which to enumerate.
@property (nonatomic, nonnull, readonly) NSArray<ARMeshAnchor *> *meshAnchors;

@end

@implementation LDNMeshAnchorEnumerator

- (LDNGeometryEnumeration)supportedEnumerations {
    return (LDNGeometryEnumerationVertex |
            LDNGeometryEnumerationFace |
            LDNGeometryEnumerationNormal);
}

- (instancetype)initWithMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    if (self = [super init]) {
        _meshAnchors = meshAnchors;
    }
    return self;
}

- (void)enumerateVerticesUsingBlock:(LDNVertexEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNVertexIndex vertexIndex;
    LDNVertex vertex;

    simd_float4 vertexPosition;
    matrix_float4x4 vertexTransform;

    LDNVertexIndex vertexIndexOffset = 0;

    for (ARMeshAnchor *meshAnchor in self.meshAnchors) {
        ARGeometrySource *vertices = meshAnchor.geometry.vertices;
        NSData *vertexData = [NSData dataWithBytesNoCopy:vertices.buffer.contents
                                                  length:vertices.buffer.length
                                            freeWhenDone:NO];

        for (LDNVertexIndex vertexInstanceIndex = 0;
             vertexInstanceIndex < vertices.count;
             vertexInstanceIndex++) {
            [vertexData getBytes:&vertexPosition
                           range:NSMakeRange(vertexInstanceIndex * vertices.stride + vertices.offset,
                                             vertices.stride)];

            vertexTransform = matrix_identity_float4x4;
            vertexTransform.columns[3] = vertexPosition;
            vertexTransform.columns[3][3] = 1;
            vertex.position = simd_mul(meshAnchor.transform, vertexTransform).columns[3];

            vertexIndex = vertexIndexOffset + vertexInstanceIndex;
            block(&vertexIndex, &vertex);
        }

        vertexIndexOffset += vertices.count;
    }
}

- (void)enumerateFacesUsingBlock:(LDNFaceEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNFaceIndex faceIndex;
    LDNFace face;

    uint32_t vertexIndices[3];

    LDNFaceIndex faceIndexOffset = 0;
    LDNVertexIndex vertexIndexOffset = 0;

    for (ARMeshAnchor *meshAnchor in self.meshAnchors) {
        ARGeometryElement *faces = meshAnchor.geometry.faces;
        NSData *faceData = [NSData dataWithBytesNoCopy:faces.buffer.contents
                                                length:faces.buffer.length
                                          freeWhenDone:NO];
        size_t faceStride = 3 * faces.bytesPerIndex;

        for (LDNFaceIndex faceInstanceIndex = 0;
             faceInstanceIndex < faces.count;
             faceInstanceIndex++) {
            [faceData getBytes:&vertexIndices
                         range:NSMakeRange(faceInstanceIndex * faceStride,
                                           faceStride)];

            face.vertexIndices[0] = vertexIndices[0] + vertexIndexOffset;
            face.vertexIndices[1] = vertexIndices[1] + vertexIndexOffset;
            face.vertexIndices[2] = vertexIndices[2] + vertexIndexOffset;

            faceIndex = faceIndexOffset + faceInstanceIndex;
            block(&faceIndex, &face);
        }

        faceIndexOffset += faces.count;
        vertexIndexOffset += meshAnchor.geometry.vertices.count;
    }
}

- (void)enumerateNormalsUsingBlock:(LDNNormalEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNNormalIndex normalIndex;
    LDNNormal normal;

    LDNNormalIndex normalIndexOffset = 0;

    for (ARMeshAnchor *meshAnchor in self.meshAnchors) {
        ARGeometrySource *normals = meshAnchor.geometry.normals;
        NSData *normalData = [NSData dataWithBytesNoCopy:normals.buffer.contents
                                                  length:normals.buffer.length
                                            freeWhenDone:NO];

        for (LDNNormalIndex normalInstanceIndex = 0;
             normalInstanceIndex < normals.count;
             normalInstanceIndex++) {
            [normalData getBytes:&normal
                           range:NSMakeRange(normalInstanceIndex * normals.stride + normals.offset,
                                             normals.stride)];

            normalIndex = normalIndexOffset + normalInstanceIndex;
            block(&normalIndex, &normal);
        }

        normalIndexOffset += normals.count;
    }
}

@end
