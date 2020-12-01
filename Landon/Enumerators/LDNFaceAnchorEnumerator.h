//
//  LDNFaceAnchorEnumerator.h
//  Landon
//
//  Created by Jack Mousseau on 12/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDNGeometryEnumerator.h"

/// A geometry enumerator which enumerates a set of face anchors.
@interface LDNFaceAnchorEnumerator : LDNGeometryEnumerator

/// The default initializer is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initialize a geometry enumerator for a given face anchor set.
///
/// @param faceAnchors The face anchors whose geometry to enumerate.
/// @return A new geometry enumerator instance.
- (nonnull instancetype)initWithFaceAnchors:(nonnull NSArray<ARFaceAnchor *> *)faceAnchors;

@end
