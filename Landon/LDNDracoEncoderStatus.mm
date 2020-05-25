//
//  LDNDracoEncoderStatus.mm
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNDracoEncoderStatus.h"
#import "LDNDracoEncoderStatus+Private.h"

@implementation LDNDracoEncoderStatus

- (instancetype)initWithStatus:(const draco::Status &)status {
    if (self = [super init]) {
        switch (status.code()) {
            case draco::Status::OK:
                _code = LDNDracoEncoderStatusCodeOK;
                break;

            case draco::Status::DRACO_ERROR:
                _code = LDNDracoEncoderStatusCodeGeneralError;
                break;

            case draco::Status::IO_ERROR:
                _code = LDNDracoEncoderStatusCodeInputOutputError;
                break;

            case draco::Status::INVALID_PARAMETER:
                _code = LDNDracoEncoderStatusCodeInvalidParameter;
                break;

            case draco::Status::UNSUPPORTED_VERSION:
                _code = LDNDracoEncoderStatusCodeInvalidUnsupportedVersion;
                break;

            case draco::Status::UNKNOWN_VERSION:
                _code = LDNDracoEncoderStatusCodeInvalidUnknownVersion;
                break;

            case draco::Status::UNSUPPORTED_FEATURE:
                _code = LDNDracoEncoderStatusCodeInvalidUnsupportedFeature;
                break;
        }

        if (status.error_msg_string().length() > 0) {
            _errorMessage = [NSString stringWithUTF8String:status.error_msg()];
        } else {
            _errorMessage = nil;
        }
    }
    return self;
}

@end
