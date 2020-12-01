//
//  LDNGeometryEnumerator.m
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNFaceAnchorEnumerator.h"
#import "LDNGeometryEnumerator.h"
#import "LDNMeshAnchorEnumerator.h"
#import "LDNPlaneAnchorEnumerator.h"

@implementation LDNGeometryEnumerator

+ (LDNGeometryEnumerator *)enumeratorForFaceAnchors:(NSArray<ARFaceAnchor *> *)faceAnchors {
    return [[LDNFaceAnchorEnumerator alloc] initWithFaceAnchors:faceAnchors];
}

+ (LDNGeometryEnumerator *)enumeratorForMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    return [[LDNMeshAnchorEnumerator alloc] initWithMeshAnchors:meshAnchors];
}

+ (LDNGeometryEnumerator *)enumeratorForPlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    return [[LDNPlaneAnchorEnumerator alloc] initWithPlaneAnchors:planeAnchors];
}

- (LDNGeometryEnumeration)supportedEnumerations {
    return LDNGeometryEnumerationNone;
}

- (instancetype)initWithPlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    return [[LDNPlaneAnchorEnumerator alloc] initWithPlaneAnchors:planeAnchors];
}

- (void)enumerateVerticesUsingBlock:(LDNVertexEnumerationBlock)block {
    // no-op
}

- (void)enumerateFacesUsingBlock:(LDNFaceEnumerationBlock)block {
    // no-op
}

@end
