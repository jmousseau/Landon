//
//  LDNPlaneAnchorEnumerator.h
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNGeometryEnumerator.h"

/// A geometry enumerator which enumerates a set of plane anchors.
@interface LDNPlaneAnchorEnumerator : LDNGeometryEnumerator

/// The default initializer is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initialize a geometry enumerator for a given plane anchor set.
///
/// @param planeAnchors The plane anchors whose geometry to enumerate.
/// @return A new geometry enumerator instance.
- (nonnull instancetype)initWithPlaneAnchors:(nonnull NSArray<ARPlaneAnchor *> *)planeAnchors;

@end
