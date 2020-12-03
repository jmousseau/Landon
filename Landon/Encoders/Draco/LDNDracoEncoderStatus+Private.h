//
//  LDNDracoEncoderStatus+Private.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "draco/compression/encode.h"

/// A Draco encoder status.
@interface LDNDracoEncoderStatus (Private)

/// Initialize a draco encoder status.
///
/// @param status The Draco encoder status with which to initialize the Draco
/// encoder status.
/// @return A new Draco encoder status instance.
- (nonnull instancetype)initWithStatus:(const draco::Status &)status;

@end
