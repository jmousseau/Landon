//
//  LDNDracoEncoderOptions.m
//  Landon
//
//  Created by Jack Mousseau on 5/25/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNDracoEncoderOptions.h"

@implementation LDNDracoEncoderOptions

- (instancetype)init {
    if (self = [super init]) {
        _encodingSpeed = 0;
        _decodingSpeed = 0;
    }
    return self;
}

@end
