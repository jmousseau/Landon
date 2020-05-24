//
//  LDNDracoEncoderStatus.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A Draco encoder status code.
///
/// - LNDDracoEncoderStatusCodeOK: Everything is OK.
/// - LNDDracoEncoderStatusCodeGeneralError: A general error.
/// - LNDDracoEncoderStatusCodeInputOutputError: An input or output error.
/// - LNDDracoEncoderStatusCodeInvalidParameter: An invalid parameter error.
/// - LNDDracoEncoderStatusCodeInvalidUnsupportedVersion: The input isn't
///   compatible with the current Draco version.
/// - LNDDracoEncoderStatusCodeInvalidUnknownVersion: The input was created
///   with an unknown Draco version.
/// - LNDDracoEncoderStatusCodeInvalidUnsupportedFeature: The input contains
///   an unsupported feature.
typedef NS_ENUM(NSUInteger, LDNDracoEncoderStatusCode) {
    LDNDracoEncoderStatusCodeOK,
    LDNDracoEncoderStatusCodeGeneralError,
    LDNDracoEncoderStatusCodeInputOutputError,
    LDNDracoEncoderStatusCodeInvalidParameter,
    LDNDracoEncoderStatusCodeInvalidUnsupportedVersion,
    LDNDracoEncoderStatusCodeInvalidUnknownVersion,
    LDNDracoEncoderStatusCodeInvalidUnsupportedFeature
};

/// A Draco encoder status.
@interface LDNDracoEncoderStatus : NSObject

/// The Draco encoder status's code.
@property (nonatomic, readonly) LDNDracoEncoderStatusCode code;

/// The Draco encoder status's error message.
@property (nonatomic, nullable, readonly) NSString *errorMessage;

/// The default initializer is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

@end
