//
//  LDNClassificationColoring.h
//  Landon
//
//  Created by Jack Mousseau on 6/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>

/// A mesh color.
typedef struct LDNSimpleColor {

    /// The mesh color's red channel.
    uint8_t red;

    /// The mesh color's blue channel.
    uint8_t blue;

    /// The mesh color's green channel.
    uint8_t green;

} NS_SWIFT_NAME(SimpleColor) LDNSimpleColor;

/// A classification coloring.
NS_SWIFT_NAME(ClassificationColoring)
@protocol LDNClassificationColoring

/// Returns the color for a given mesh classification.
///
/// @param meshClassification The mesh classification for which to return a
/// color.
/// @return The color for the given mesh classfication.
- (LDNSimpleColor)colorForMeshClassification:(ARMeshClassification)meshClassification NS_SWIFT_NAME(colorFor(meshClassification:));

/// Returns the color for a given plane classification.
///
/// @param planeClassification The plane classficiation for which to return a
/// color.
/// @return The color for the given plane classification.
- (LDNSimpleColor)colorForPlaneClassification:(ARPlaneClassification)planeClassification NS_SWIFT_NAME(colorFor(planeClassification:));

@end

/// The default classification coloring.
NS_SWIFT_NAME(DefaultClassificationColoring)
@interface LDNDefaultClassificationColoring : NSObject <
    LDNClassificationColoring
>

@end
