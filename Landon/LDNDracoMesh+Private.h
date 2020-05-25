//
//  LDNDracoMesh+Private.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <Landon/Landon.h>

/// A Draco mesh.
@interface LDNDracoMesh (Private)

/// The Draco mesh's backing mesh.
@property (nonatomic) std::shared_ptr<draco::Mesh> mesh;

@end
