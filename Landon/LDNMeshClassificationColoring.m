//
//  LDNMeshClassificationColoring.m
//  Landon
//
//  Created by Jack Mousseau on 6/1/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNMeshClassificationColoring.h"

@implementation LDNDefaultMeshClassificationColoring

- (LDNMeshColor)colorForMeshClassification:(ARMeshClassification)meshClassification {
    switch (meshClassification) {
        case ARMeshClassificationNone:
            return (LDNMeshColor) {
                .red = 0,
                .blue = 0,
                .green = 0
            };

        case ARMeshClassificationWall:
            return (LDNMeshColor) {
                .red = 255,
                .blue = 0,
                .green = 0
            };

        case ARMeshClassificationFloor:
            return (LDNMeshColor) {
                .red = 0,
                .blue = 255,
                .green = 0
            };

        case ARMeshClassificationCeiling:
            return (LDNMeshColor) {
                .red = 0,
                .blue = 0,
                .green = 255
            };

        case ARMeshClassificationTable:
            return (LDNMeshColor) {
                .red = 255,
                .blue = 255,
                .green = 0
            };

        case ARMeshClassificationSeat:
            return (LDNMeshColor) {
                .red = 255,
                .blue = 0,
                .green = 255
            };

        case ARMeshClassificationWindow:
            return (LDNMeshColor) {
                .red = 0,
                .blue = 255,
                .green = 255
            };

        case ARMeshClassificationDoor:
            return (LDNMeshColor) {
                .red = 255,
                .blue = 255,
                .green = 255
            };
    }
}

@end
