//
//  LDNClassificationColoring.m
//  Landon
//
//  Created by Jack Mousseau on 6/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNClassificationColoring.h"

@implementation LDNDefaultClassificationColoring

- (LDNSimpleColor)colorForMeshClassification:(ARMeshClassification)meshClassification {
    switch (meshClassification) {
        case ARMeshClassificationNone:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 0,
                .green = 0
            };

        case ARMeshClassificationWall:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 0,
                .green = 0
            };

        case ARMeshClassificationFloor:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 255,
                .green = 0
            };

        case ARMeshClassificationCeiling:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 0,
                .green = 255
            };

        case ARMeshClassificationTable:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 255,
                .green = 0
            };

        case ARMeshClassificationSeat:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 0,
                .green = 255
            };

        case ARMeshClassificationWindow:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 255,
                .green = 255
            };

        case ARMeshClassificationDoor:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 255,
                .green = 255
            };
    }
}

- (LDNSimpleColor)colorForPlaneClassification:(ARPlaneClassification)planeClassification {
    switch (planeClassification) {
        case ARPlaneClassificationNone:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 0,
                .green = 0
            };

        case ARPlaneClassificationWall:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 0,
                .green = 0
            };

        case ARPlaneClassificationFloor:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 255,
                .green = 0
            };

        case ARPlaneClassificationCeiling:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 0,
                .green = 255
            };

        case ARPlaneClassificationTable:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 255,
                .green = 0
            };

        case ARPlaneClassificationSeat:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 0,
                .green = 255
            };

        case ARPlaneClassificationWindow:
            return (LDNSimpleColor) {
                .red = 0,
                .blue = 255,
                .green = 255
            };

        case ARPlaneClassificationDoor:
            return (LDNSimpleColor) {
                .red = 255,
                .blue = 255,
                .green = 255
            };
    }
}

@end
