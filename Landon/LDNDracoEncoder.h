//
//  LDNDracoEncoder.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

#import "LDNDracoEncoderResult.h"

/// A draco encoder.
NS_SWIFT_NAME(DracoEncoder)
@interface LDNDracoEncoder : NSObject

/// Encode a given set of mesh anchors into a single Draco mesh.
///
/// TODO: Convert each mesh anchor's vertices to world space.
///
/// @param meshAnchors The mesh anchors to encode.
/// @return An encoder result that contains the encoded Draco data, if the
/// encode was successful.
+ (nonnull LDNDracoEncoderResult *)encodeMeshAnchors:(nonnull NSArray<ARMeshAnchor *> *)meshAnchors NS_SWIFT_NAME(encode(meshAnchors:));

/// The default initialize is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

@end
