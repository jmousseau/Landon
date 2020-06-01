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

        draco::GeometryAttribute positionAttribute;
        positionAttribute.Init(draco::GeometryAttribute::POSITION,
                               nullptr, 3, draco::DT_FLOAT32, false,
                               draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);

        const int positionAttributeId = mesh.AddAttribute(positionAttribute,
                                                          true, mesh.num_points());

        uint32_t encodedVertexCount = 0;

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

    // Encode normals.
    {
        LDNSignpostBegin("Encode Normals");

        draco::GeometryAttribute normalAttribute;
        normalAttribute.Init(draco::GeometryAttribute::NORMAL,
                             nullptr, 3, draco::DT_FLOAT32, false,
                             draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);

        const int normalAttributeId = mesh.AddAttribute(normalAttribute,
                                                        true, mesh.num_points());

        uint32_t encodedNormalCount = 0;

        simd_float3 normal;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometrySource *normals = meshAnchor.geometry.normals;
            NSData *normalData = [NSData dataWithBytesNoCopy:normals.buffer.contents
                                                      length:normals.buffer.length
                                                freeWhenDone:NO];

            for (uint32_t normalAttributeIndex = 0;
                 normalAttributeIndex < normals.count;
                 normalAttributeIndex++) {
                [normalData getBytes:&normal
                               range:NSMakeRange(normalAttributeIndex * normals.stride + normals.offset,
                                                 normals.stride)];

                // Must access the attribute by identifier. Otherwise, attribute
                // buffer will be uninitialized.
                uint32_t offsetNormalAttributeIndex = normalAttributeIndex + encodedNormalCount;
                mesh.attribute(normalAttributeId)->SetAttributeValue(draco::AttributeValueIndex(offsetNormalAttributeIndex),
                                                                     &normal);
            }

            encodedNormalCount += normals.count;
        }

        LDNSignpostEnd("Encode Normals");
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

    // Encode classification.
    {
        LDNSignpostBegin("Encode Classification");

        draco::GeometryAttribute classificationAttribute;
        classificationAttribute.Init(draco::GeometryAttribute::COLOR,
                                     nullptr, 3, draco::DT_UINT8, false,
                                     draco::DataTypeLength(draco::DT_UINT8) * 3, 0);

        const int classificationAttributeId = mesh.AddAttribute(classificationAttribute,
                                                                true, mesh.num_points());

        uint32_t encodedClassificationCount = 0;

        draco::Mesh::Face face;
        uint8_t classification;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometrySource *classifications = meshAnchor.geometry.classification;
            NSData *classificationData = [NSData dataWithBytesNoCopy:classifications.buffer.contents
                                                              length:classifications.buffer.length
                                                        freeWhenDone:NO];

            for (draco::FaceIndex classificationIndex = draco::FaceIndex(0);
                 classificationIndex < (uint32_t)classifications.count;
                 classificationIndex++) {
                [classificationData getBytes:&classification
                                       range:NSMakeRange(classificationIndex.value() *
                                                         classifications.stride +
                                                         classifications.offset,
                                                         classifications.stride)];

                // Reuse the face to vertex mapping created above.
                face = mesh.face(classificationIndex + encodedClassificationCount);

                LDNMeshColor classificationColor = [options.meshClassificationColoring
                                                    colorForMeshClassification:(ARMeshClassification)classification];

                for (uint32_t vertexIndex = 0; vertexIndex < 3; vertexIndex++) {
                    // Must access the attribute by identifier. Otherwise,
                    // attribute buffer will be uninitialized.
                    mesh.attribute(classificationAttributeId)->SetAttributeValue(draco::AttributeValueIndex(face[vertexIndex].value()),
                                                                                  &classificationColor);
                }
            }

            encodedClassificationCount += classifications.count;
        }

        LDNSignpostEnd("Encode Classification");
    }

    LDNSignpostBegin("Encode Mesh Buffer");

    draco::Encoder encoder;
    draco::EncoderBuffer buffer;

    encoder.SetSpeedOptions(options.encodingSpeed, options.decodingSpeed);

    draco::Status status = encoder.EncodeMeshToBuffer(mesh, &buffer);
    NSData *data = [NSData dataWithBytes:buffer.buffer()->data()
                                  length:buffer.buffer()->size()];

    LDNSignpostEnd("Encode Mesh Buffer");

    return [[LDNDracoEncoderResult alloc] initWithStatus:[[LDNDracoEncoderStatus alloc] initWithStatus:status]
                                                    data:data];
}

@end
