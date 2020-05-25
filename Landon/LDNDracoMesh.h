//
//  LDNDracoMesh.h
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

/// A Draco mesh.
@interface LDNDracoMesh : NSObject

/// The default initializer is unavailable.
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initialize a Draco mesh.
///
/// @param meshGeometry The mesh geometry with which to initialize the Draco
/// mesh.
/// @return A new Draco mesh instance.
- (nonnull instancetype)initWithMeshGeometry:(nonnull ARMeshGeometry *)meshGeometry;

@end
