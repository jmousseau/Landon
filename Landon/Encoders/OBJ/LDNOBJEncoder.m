//
//  LDNOBJEncoder.m
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNGeometryEnumerator.h"
#import "LDNOBJEncoder.h"
#import "LDNProfile.h"

#define LDN_OBJ_STRING_FACE @"f %u %u %u\n"
#define LDN_OBJ_STRING_VERTEX @"v %.6f %.6f %.6f\n"

@implementation LDNOBJEncoder

+ (NSData *)encodeFaceAnchors:(NSArray<ARFaceAnchor *> *)faceAnchors {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForFaceAnchors:faceAnchors];
    return [self encodeGeometryEnumerator:enumerator];
}

+ (NSData *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForMeshAnchors:meshAnchors];
    return [self encodeGeometryEnumerator:enumerator];
}

+ (NSData *)encodePlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForPlaneAnchors:planeAnchors];
    return [self encodeGeometryEnumerator:enumerator];
}

+ (NSData *)encodeGeometryEnumerator:(LDNGeometryEnumerator *)geometryEnumerator {
    LDNLogCreate("OBJ Encoder");

    NSMutableString *obj = [[NSMutableString alloc] init];

    if (geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationVertex) {
        LDNSignpostBegin(LDN_INTERVAL_ENCODE_VERTICES);

        [geometryEnumerator enumerateVerticesUsingBlock:^(LDNVertexIndex *vertexIndex,
                                                          LDNVertex *vertex) {
            simd_float4 position = (*vertex).position;
            [obj appendFormat:LDN_OBJ_STRING_VERTEX,
             position.x,
             position.y,
             position.z];
        }];

        LDNSignpostEnd(LDN_INTERVAL_ENCODE_VERTICES);
    }

    if (geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationFace) {
        LDNSignpostBegin(LDN_INTERVAL_ENCODE_FACES);

        [geometryEnumerator enumerateFacesUsingBlock:^(LDNFaceIndex *triangleIndex,
                                                       LDNFace *triangle) {
            LDNFace _triangle = *triangle;
            [obj appendFormat:LDN_OBJ_STRING_FACE,
             _triangle.vertexIndices[0] + 1,
             _triangle.vertexIndices[1] + 1,
             _triangle.vertexIndices[2] + 1];
        }];

        LDNSignpostEnd(LDN_INTERVAL_ENCODE_FACES);
    }

    return [obj dataUsingEncoding:NSUTF8StringEncoding];
}

@end
