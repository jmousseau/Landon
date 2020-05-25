//
//  LDNDracoEncoderResult+Private.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNDracoEncoderResult.h"

/// A Draco encoder result.
@interface LDNDracoEncoderResult (Private)

/// Initialize a Draco encoder result.
///
/// @param status The Draco encoder result's status.
/// @param data The Draco encoder result's data.
/// @return A new Draco encoder result instance.
- (nonnull instancetype)initWithStatus:(nonnull LDNDracoEncoderStatus *)status
                                  data:(nullable NSData *)data;

@end
