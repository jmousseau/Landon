//
//  LDNOBJEncoder.m
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNOBJEncoder.h"
#import "LDNProfile.h"

@implementation LDNOBJEncoder

+ (NSData *)encodePlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    LDNLogCreate("OBJ Plane Encoder");

    NSMutableString *obj = [[NSMutableString alloc] init];

    {
        LDNSignpostBegin(LDN_INTERVAL_ENCODE_VERTICES);

        matrix_float4x4 vertexTransform;
        simd_float4 vertexPosition;

        uint32_t vertexStride = sizeof(simd_float3);

        for (ARPlaneAnchor *planeAnchor in planeAnchors) {
            ARPlaneGeometry *planeGeometry = planeAnchor.geometry;
            NSData *vertexData = [NSData dataWithBytesNoCopy:(void *)planeGeometry.vertices
                                                      length:planeGeometry.vertexCount * vertexStride
                                                freeWhenDone:NO];

            for (u_int32_t vertexIndex = 0;
                 vertexIndex < planeGeometry.vertexCount;
                 vertexIndex++) {
                [vertexData getBytes:&vertexPosition
                               range:NSMakeRange(vertexIndex * vertexStride, vertexStride)];
                vertexTransform = matrix_identity_float4x4;
                vertexTransform.columns[3] = vertexPosition;
                vertexTransform.columns[3][3] = 1;

                vertexPosition = simd_mul(planeAnchor.transform, vertexTransform).columns[3];
                [obj appendFormat:@"v %.6f %.6f %.6f\n", vertexPosition.x, vertexPosition.y, vertexPosition.z];
            }
        }

        LDNSignpostEnd(LDN_INTERVAL_ENCODE_VERTICES);
    }

    {
        LDNSignpostBegin(LDN_INTERVAL_ENCODE_FACES);

        uint32_t vertexIndexOffset = 0;

        uint32_t triangleStride = 3 * sizeof(int16_t);

        int16_t triangle[3];

        for (ARPlaneAnchor *planeAnchor in planeAnchors) {
            ARPlaneGeometry *planeGeometry = planeAnchor.geometry;
            NSData *faceData = [NSData dataWithBytesNoCopy:(void *)planeGeometry.triangleIndices
                                                    length:planeGeometry.triangleCount * triangleStride
                                              freeWhenDone:NO];

            for (NSUInteger faceIndex = 0;
                 faceIndex < planeGeometry.triangleCount;
                 faceIndex++) {
                [faceData getBytes:&triangle
                             range:NSMakeRange(faceIndex * triangleStride, triangleStride)];
                [obj appendFormat:@"f %u %u %u\n",
                 (uint32_t)triangle[0] + vertexIndexOffset + 1,
                 (uint32_t)triangle[1] + vertexIndexOffset + 1,
                 (uint32_t)triangle[2] + vertexIndexOffset + 1];
            }

            vertexIndexOffset += planeGeometry.vertexCount;
        }

        LDNSignpostEnd(LDN_INTERVAL_ENCODE_FACES);
    }

    return [obj dataUsingEncoding:NSUTF8StringEncoding];
}

@end
