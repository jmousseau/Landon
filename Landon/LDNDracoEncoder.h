//
//  LDNDracoEncoder.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDNDracoEncoderResult.h"
#import "LDNDracoMesh.h"

/// A draco encoder.
@interface LDNDracoEncoder : NSObject

/// Encode a given Draco mesh.
///
/// @param mesh The Draco mesh to encode.
/// @return A Draco encoder result that contains the encoded data, if the encode
/// was successful.
+ (nonnull LDNDracoEncoderResult *)encodeMesh:(nonnull LDNDracoMesh *)mesh;

@end
