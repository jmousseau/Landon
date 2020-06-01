//
//  LDNMeshClassificationColoring.h
//  Landon
//
//  Created by Jack Mousseau on 6/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

/// A mesh color.
typedef struct LDNMeshColor {

    /// The mesh color's red channel.
    uint8_t red;

    /// The mesh color's blue channel.
    uint8_t blue;

    /// The mesh color's green channel.
    uint8_t green;

} NS_SWIFT_NAME(MeshColor) LDNMeshColor;

/// A mesh classification coloring.
NS_SWIFT_NAME(MeshClassificationColoring)
@protocol LDNMeshClassificationColoring

/// Returns the color for a given mesh classification.
/// @param meshClassification The mesh classification for which to return a
/// color.
- (LDNMeshColor)colorForMeshClassification:(ARMeshClassification)meshClassification NS_SWIFT_NAME(colorFor(meshClassification:));

@end

/// The default mesh classification coloring.
NS_SWIFT_NAME(DefaultMeshClassificationColoring)
@interface LDNDefaultMeshClassificationColoring : NSObject <
    LDNMeshClassificationColoring
>

@end
