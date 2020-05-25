//
//  LDNDracoEncoder.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

#import "LDNDracoEncoderOptions.h"
#import "LDNDracoEncoderResult.h"

/// A draco encoder.
NS_SWIFT_NAME(DracoEncoder)
@interface LDNDracoEncoder : NSObject

/// Encode a given set of mesh anchors into a single Draco mesh using the
/// default encoder options.
///
/// @param meshAnchors The mesh anchors to encode.
/// @return An encoder result that contains the encoded Draco data, if the
/// encode was successful.
+ (nonnull LDNDracoEncoderResult *)encodeMeshAnchors:(nonnull NSArray<ARMeshAnchor *> *)meshAnchors NS_SWIFT_NAME(encode(meshAnchors:));

/// Encode a given set of mesh anchors into a single Draco mesh.
///
/// @param meshAnchors The mesh anchors to encode.
/// @param options Encoder options used for encoding.
/// @return An encoder result that contains the encoded Draco data, if the
/// encode was successful.
+ (nonnull LDNDracoEncoderResult *)encodeMeshAnchors:(nonnull NSArray<ARMeshAnchor *> *)meshAnchors
                                             options:(nonnull LDNDracoEncoderOptions *)options NS_SWIFT_NAME(encode(meshAnchors:options:));

/// The default initialize is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

@end
