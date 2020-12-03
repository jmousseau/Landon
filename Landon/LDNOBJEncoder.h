//
//  LDNOBJEncoder.h
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

/// A Wavefront OBJect encoder.
NS_SWIFT_NAME(OBJEncoder)
@interface LDNOBJEncoder : NSObject

/// Encode a given set of face anchors into a single OBJ mesh.
///
/// @param faceAnchors The face anchors to encode.
/// @return The OBJ data, if the encode was successful.
+ (nullable NSData *)encodeFaceAnchors:(nonnull NSArray<ARFaceAnchor *> *)faceAnchors NS_SWIFT_NAME(encode(faceAnchors:));

/// Encode a given set of mesh anchors into a single OBJ mesh.
///
/// @param meshAnchors The mesh anchors to encode.
/// @return The OBJ data, if the encode was successful.
+ (nullable NSData *)encodeMeshAnchors:(nonnull NSArray<ARMeshAnchor *> *)meshAnchors NS_SWIFT_NAME(encode(meshAnchors:));

/// Encode a given set of plane anchors into a single OBJ mesh.
///
/// @param planeAnchors The plane anchors to encode.
/// @return The OBJ data, if the encode was successful.
+ (nullable NSData *)encodePlaneAnchors:(nonnull NSArray<ARPlaneAnchor *> *)planeAnchors NS_SWIFT_NAME(encode(planeAnchors:));

@end
