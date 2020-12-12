//
//  LDNPlaneAnchorEnumerator.m
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNPlaneAnchorEnumerator.h"

/// A geometry enumerator which enumerates a set of plane anchors.
@interface LDNPlaneAnchorEnumerator ()

/// The set of plane anchors which to enumerate.
@property (nonatomic, nonnull, readonly) NSArray<ARPlaneAnchor *> *planeAnchors;

@end

@implementation LDNPlaneAnchorEnumerator

- (LDNGeometryEnumeration)supportedEnumerations {
    return (LDNGeometryEnumerationVertex |
            LDNGeometryEnumerationFace |
            LDNGeometryEnumerationClassification);
}

- (instancetype)initWithPlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    if (self = [super init]) {
        _planeAnchors = planeAnchors;
    }
    return self;
}

- (LDNInteger)totalVertexCount {
    LDNInteger totalVertexCount = 0;

    for (ARPlaneAnchor *planeAnchor in self.planeAnchors) {
        totalVertexCount += planeAnchor.geometry.vertexCount;
    }

    return totalVertexCount;
}

- (LDNInteger)totalFaceCount {
    LDNInteger totalFaceCount = 0;

    for (ARPlaneAnchor *planeAnchor in self.planeAnchors) {
        totalFaceCount += planeAnchor.geometry.triangleCount;
    }

    return totalFaceCount;
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

    for (ARPlaneAnchor *planeAnchor in self.planeAnchors) {
        ARPlaneGeometry *planeGeometry = planeAnchor.geometry;
        NSData *vertexData = [NSData dataWithBytesNoCopy:(void *)planeGeometry.vertices
                                                  length:planeGeometry.vertexCount * vertexStride
                                            freeWhenDone:NO];

        for (LDNVertexIndex vertexInstanceIndex = 0;
             vertexInstanceIndex < planeGeometry.vertexCount;
             vertexInstanceIndex++) {
            [vertexData getBytes:&vertexPosition
                           range:NSMakeRange(vertexInstanceIndex * vertexStride, vertexStride)];

            vertexTransform = matrix_identity_float4x4;
            vertexTransform.columns[3] = vertexPosition;
            vertexTransform.columns[3][3] = 1;
            vertex.position = simd_mul(planeAnchor.transform, vertexTransform).columns[3];

            vertexIndex = vertexIndexOffset + vertexInstanceIndex;
            block(&vertexIndex, &vertex);
        }

        vertexIndexOffset += planeGeometry.vertexCount;
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

    for (ARPlaneAnchor *planeAnchor in self.planeAnchors) {
        ARPlaneGeometry *planeGeometry = planeAnchor.geometry;
        NSData *faceData = [NSData dataWithBytesNoCopy:(void *)planeGeometry.triangleIndices
                                                length:planeGeometry.triangleCount * faceStride
                                          freeWhenDone:NO];

        for (LDNFaceIndex faceInstanceIndex = 0;
             faceInstanceIndex < planeGeometry.triangleCount;
             faceInstanceIndex++) {
            [faceData getBytes:&vertexIndices
                         range:NSMakeRange(faceInstanceIndex * faceStride, faceStride)];

            face.vertexIndices[0] = ((LDNFaceIndex)vertexIndices[0]) + vertexIndexOffset;
            face.vertexIndices[1] = ((LDNFaceIndex)vertexIndices[1]) + vertexIndexOffset;
            face.vertexIndices[2] = ((LDNFaceIndex)vertexIndices[2]) + vertexIndexOffset;

            faceIndex = faceInstanceIndex + faceIndexOffset;
            block(&faceIndex, &face);
        }

        faceIndexOffset += planeGeometry.triangleCount;
        vertexIndexOffset += planeGeometry.vertexCount;
    }
}

- (void)enumerateClassificationsUsingBlock:(LDNClassificationEnumerationBlock)block {
    if (!block) {
        return;
    }

    LDNClassificationIndex classificationIndex;
    LDNClassification classification;

    LDNFaceIndex faceIndexOffset = 0;

    for (ARPlaneAnchor *planeAnchor in self.planeAnchors) {
        ARPlaneGeometry *planeGeometry = planeAnchor.geometry;
        classification = planeAnchor.classification;

        for (LDNFaceIndex faceInstanceIndex = 0;
             faceInstanceIndex < planeGeometry.triangleCount;
             faceInstanceIndex++) {
            classificationIndex = faceIndexOffset + faceInstanceIndex;
            block(&classificationIndex, &classification);
        }

        faceIndexOffset += planeGeometry.triangleCount;
    }
}

@end
