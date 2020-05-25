//
//  LDNDracoEncoderOptions.h
//  Landon
//
//  Created by Jack Mousseau on 5/25/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Draco encoder options.
NS_SWIFT_NAME(DracoEncoder.Options)
@interface LDNDracoEncoderOptions : NSObject

/// The encoding speed used by the encoder. Defaults to 0.
///
/// A value between 0 and 10, where 0 is the slowest, but provides the best
/// compression.
@property (nonatomic) int encodingSpeed;

/// The decoding speed used by the encoder. Defaults to 0.
///
/// A value between 0 and 10, where 0 is the slowest, but provides the best
/// compression.
@property (nonatomic) int decodingSpeed;

@end
