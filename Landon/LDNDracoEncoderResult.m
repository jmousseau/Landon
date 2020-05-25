//
//  LDNDracoEncoderResult.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNDracoEncoderResult.h"
#import "LDNDracoEncoderResult+Private.h"

@implementation LDNDracoEncoderResult

- (instancetype)initWithStatus:(LDNDracoEncoderStatus *)status
                          data:(NSData *)data {
    if (self = [super init]) {
        _status = status;
        _data = data;
    }
    return self;
}

@end
