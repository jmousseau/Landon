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

#define LDNAssertUnsupportedEnumeration(enumeration) \
    NSAssert(NO, @"%@ doesn't support %@ enumeration.", NSStringFromClass([self class]), enumeration)

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

- (LDNInteger)totalVertexCount {
    return 0;
}

- (LDNInteger)totalFaceCount {
    return 0;
}

- (void)enumerateVerticesUsingBlock:(LDNVertexEnumerationBlock)block {
    if (~self.supportedEnumerations & LDNGeometryEnumerationVertex) {
        LDNAssertUnsupportedEnumeration(@"vertex");
    }
}

- (void)enumerateFacesUsingBlock:(LDNFaceEnumerationBlock)block {
    if (~self.supportedEnumerations & LDNGeometryEnumerationFace) {
        LDNAssertUnsupportedEnumeration(@"face");
    }
}

- (void)enumerateNormalsUsingBlock:(LDNNormalEnumerationBlock)block {
    if (~self.supportedEnumerations & LDNGeometryEnumerationNormal) {
        LDNAssertUnsupportedEnumeration(@"normal");
    }
}

- (void)enumerateClassificationsUsingBlock:(LDNClassificationEnumerationBlock)block {
    if (~self.supportedEnumerations & LDNGeometryEnumerationClassification) {
        LDNAssertUnsupportedEnumeration(@"classification");
    }
}

@end
