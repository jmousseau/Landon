//
//  LDNDracoEncoder.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "draco/compression/encode.h"
#import "LDNDracoEncoder.h"
#import "LDNDracoEncoderResult+Private.h"
#import "LDNDracoEncoderStatus+Private.h"
#import "LDNDracoMesh+Private.h"

@implementation LDNDracoEncoder

+ (LDNDracoEncoderResult *)encodeMesh:(LDNDracoMesh *)mesh {
    draco::Encoder encoder;
    draco::EncoderBuffer buffer;

    encoder.SetSpeedOptions(5, 5);

    draco::Status status = encoder.EncodeMeshToBuffer(*mesh.mesh.get(), &buffer);
    NSData *data = [NSData dataWithBytes:buffer.buffer()->data()
                                  length:buffer.buffer()->size()];

    return [[LDNDracoEncoderResult alloc] initWithStatus:[[LDNDracoEncoderStatus alloc] initWithStatus:status]
                                                    data:data];
}

@end
