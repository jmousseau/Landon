//
//  LDNDracoEncoderResult.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDNDracoEncoderStatus.h"

/// A Draco encoder result.
NS_SWIFT_NAME(DracoEncoder.Result)
@interface LDNDracoEncoderResult : NSObject

/// The Draco encoder result's status.
@property (nonatomic, nonnull, readonly) LDNDracoEncoderStatus *status;

/// The Draco encoder result's encoded data.
@property (nonatomic, nullable, readonly) NSData *data;

@end

