//
//  LDNFaceAnchorEnumerator.m
//  Landon
//
//  Created by Jack Mousseau on 12/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNFaceAnchorEnumerator.h"

/// A geometry enumerator which enumerates a set of face anchors.
@interface LDNFaceAnchorEnumerator ()

/// The set of face anchors which to enumerate.
@property (nonatomic, nonnull, readonly) NSArray<ARFaceAnchor *> *faceAnchors;

@end

@implementation LDNFaceAnchorEnumerator

- (LDNGeometryEnumeration)supportedEnumerations {
    return (LDNGeometryEnumerationVertex |
            LDNGeometryEnumerationFace);
}

- (instancetype)initWithFaceAnchors:(NSArray<ARFaceAnchor *> *)faceAnchors {
    if (self = [super init]) {
        _faceAnchors = faceAnchors;
    }
    return self;
}

- (void)enumerateVerticesUsingBlock:(LDNVertexEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNVertexIndex vertexIndex;
    LDNVertex vertex;

    size_t vertexStride = sizeof(simd_float3);
    simd_float4 vertexPosition;
    matrix_float4x4 vertexTransform;

    LDNVertexIndex vertexIndexOffset = 0;

    for (ARFaceAnchor *faceAnchor in self.faceAnchors) {
        ARFaceGeometry *faceGeometry = faceAnchor.geometry;
        NSData *vertexData = [NSData dataWithBytesNoCopy:(void *)faceGeometry.vertices
                                                  length:faceGeometry.vertexCount * vertexStride
                                            freeWhenDone:NO];

        for (LDNVertexIndex vertexInstanceIndex = 0;
             vertexInstanceIndex < faceGeometry.vertexCount;
             vertexInstanceIndex++) {
            [vertexData getBytes:&vertexPosition
                           range:NSMakeRange(vertexInstanceIndex * vertexStride, vertexStride)];

            vertexTransform = matrix_identity_float4x4;
            vertexTransform.columns[3] = vertexPosition;
            vertexTransform.columns[3][3] = 1;
            vertex.position = simd_mul(faceAnchor.transform, vertexTransform).columns[3];

            vertexIndex = vertexIndexOffset + vertexInstanceIndex;
            block(&vertexIndex, &vertex);
        }

        vertexIndexOffset += faceGeometry.vertexCount;
    }
}

- (void)enumerateFacesUsingBlock:(LDNFaceEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNFaceIndex faceIndex;
    LDNFace face;

    size_t faceStride = 3 * sizeof(int16_t);
    int16_t vertexIndices[3];

    LDNFaceIndex faceIndexOffset = 0;
    LDNVertexIndex vertexIndexOffset = 0;

    for (ARFaceAnchor *faceAnchor in self.faceAnchors) {
        ARFaceGeometry *faceGeometry = faceAnchor.geometry;
        NSData *faceData = [NSData dataWithBytesNoCopy:(void *)faceGeometry.triangleIndices
                                                length:faceGeometry.triangleCount * faceStride
                                          freeWhenDone:NO];

        for (LDNFaceIndex faceInstanceIndex = 0;
             faceInstanceIndex < faceGeometry.triangleCount;
             faceInstanceIndex++) {
            [faceData getBytes:&vertexIndices
                         range:NSMakeRange(faceInstanceIndex * faceStride, faceStride)];

            face.vertexIndices[0] = ((LDNFaceIndex)vertexIndices[0]) + vertexIndexOffset;
            face.vertexIndices[1] = ((LDNFaceIndex)vertexIndices[1]) + vertexIndexOffset;
            face.vertexIndices[2] = ((LDNFaceIndex)vertexIndices[2]) + vertexIndexOffset;

            faceIndex = faceInstanceIndex + faceIndexOffset;
            block(&faceIndex, &face);
        }

        faceIndexOffset += faceGeometry.triangleCount;
        vertexIndexOffset += faceGeometry.vertexCount;
    }
}

@end
