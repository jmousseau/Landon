//
//  LDNDracoEncoder.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <simd/simd.h>

#import "draco/compression/encode.h"
#import "draco/mesh/mesh.h"
#import "LDNDracoEncoder.h"
#import "LDNDracoEncoderResult+Private.h"
#import "LDNDracoEncoderStatus+Private.h"
#import "LDNProfile.h"

@implementation LDNDracoEncoder

+ (LDNDracoEncoderResult *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    return [self encodeMeshAnchors:meshAnchors
                           options:[[LDNDracoEncoderOptions alloc] init]];
}

+ (LDNDracoEncoderResult *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors
                                     options:(LDNDracoEncoderOptions *)options {
    LDNLogCreate("Draco Encoder");

    draco::Mesh mesh;

    // Allocate space for vertices and faces.
    {
        LDNSignpostBegin("Allocate Mesh");

        uint32_t vertexCount = 0;
        uint32_t faceCount = 0;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            vertexCount += meshAnchor.geometry.vertices.count;
            faceCount += meshAnchor.geometry.faces.count;
        }

        mesh.set_num_points(draco::PointIndex::ValueType(vertexCount));
        mesh.SetNumFaces(draco::PointIndex::ValueType(faceCount));

        LDNSignpostEnd("Allocate Mesh");
    }


    // Encode vertices.
    {
        LDNSignpostBegin("Encode Vertices");

        uint32_t encodedVertexCount = 0;

        draco::GeometryAttribute positionAttribute;
        positionAttribute.Init(draco::GeometryAttribute::POSITION,
                               nullptr, 3, draco::DT_FLOAT32, false,
                               draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);


        const int positionAttributeId = mesh.AddAttribute(positionAttribute,
                                                          true, mesh.num_points());

        matrix_float4x4 vertexTransform;
        simd_float4 vertexPosition;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometrySource *vertices = meshAnchor.geometry.vertices;
            NSData *vertexData = [NSData dataWithBytesNoCopy:vertices.buffer.contents
                                                      length:vertices.buffer.length
                                                freeWhenDone:NO];

            for (uint32_t vertexAttributeIndex = 0;
                 vertexAttributeIndex < vertices.count;
                 vertexAttributeIndex++) {
                [vertexData getBytes:&vertexPosition
                               range:NSMakeRange(vertexAttributeIndex * vertices.stride + vertices.offset,
                                                 vertices.stride)];
                vertexTransform = matrix_identity_float4x4;
                vertexTransform.columns[3] = vertexPosition;
                vertexTransform.columns[3][3] = 1;

                vertexPosition = simd_mul(meshAnchor.transform, vertexTransform).columns[3];

                // Must access the attribute by identifier. Otherwise, attribute
                // buffer will be uninitialized.
                uint32_t offsetVertexAttributeIndex = vertexAttributeIndex + encodedVertexCount;
                mesh.attribute(positionAttributeId)->SetAttributeValue(draco::AttributeValueIndex(offsetVertexAttributeIndex),
                                                                       &vertexPosition);
            }

            encodedVertexCount += vertices.count;
        }

        LDNSignpostEnd("Encode Vertices");
    }

    // Encode faces.
    {
        LDNSignpostBegin("Encode Faces");

        uint32_t encodedFaceCount = 0;
        uint32_t vertexIndexOffset = 0;

        draco::Mesh::Face face;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometryElement *faces = meshAnchor.geometry.faces;
            NSData *faceData = [NSData dataWithBytesNoCopy:faces.buffer.contents
                                                    length:faces.buffer.length
                                              freeWhenDone:NO];
            uint64_t faceStride = 3 * faces.bytesPerIndex;

            for (draco::FaceIndex faceIndex = draco::FaceIndex(0);
                 faceIndex < (uint32_t)faces.count;
                 faceIndex++) {
                [faceData getBytes:face.data()
                             range:NSMakeRange(faceIndex.value() * faceStride, faceStride)];

                face[0] += vertexIndexOffset;
                face[1] += vertexIndexOffset;
                face[2] += vertexIndexOffset;

                mesh.SetFace(faceIndex + encodedFaceCount, face);
            }

            encodedFaceCount += faces.count;
            vertexIndexOffset += meshAnchor.geometry.vertices.count;
        }

        LDNSignpostEnd("Encode Faces");
    }

    LDNSignpostBegin("Encode Mesh Buffer");

    draco::Encoder encoder;
    draco::EncoderBuffer buffer;

    encoder.SetSpeedOptions(options.encodingSpeed, options.decodingSpeed);

    draco::Status status = encoder.EncodeMeshToBuffer(mesh, &buffer);
    NSData *data = [NSData dataWithBytes:buffer.buffer()->data()
                                  length:buffer.buffer()->size()];

    return [[LDNDracoEncoderResult alloc] initWithStatus:[[LDNDracoEncoderStatus alloc] initWithStatus:status]
                                                    data:data];

    LDNSignpostEnd("Encode Mesh Buffer");
}

@end
