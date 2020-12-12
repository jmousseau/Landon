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
#import "LDNGeometryEnumerator.h"
#import "LDNProfile.h"

@implementation LDNDracoEncoder

// MARK: - Face Anchors

+ (LDNDracoEncoderResult *)encodeFaceAnchors:(NSArray<ARFaceAnchor *> *)faceAnchors {
    return [self encodeFaceAnchors:faceAnchors
                           options:[[LDNDracoEncoderOptions alloc] init]];
}

+ (LDNDracoEncoderResult *)encodeFaceAnchors:(NSArray<ARFaceAnchor *> *)faceAnchors
                                     options:(LDNDracoEncoderOptions *)options {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForFaceAnchors:faceAnchors];
    return [self encodeGeometryEnumerator:enumerator options:options];
}

// MARK: - Mesh Anchors

+ (LDNDracoEncoderResult *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    return [self encodeMeshAnchors:meshAnchors
                           options:[[LDNDracoEncoderOptions alloc] init]];
}

+ (LDNDracoEncoderResult *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors
                                     options:(LDNDracoEncoderOptions *)options {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForMeshAnchors:meshAnchors];
    return [self encodeGeometryEnumerator:enumerator options:options];
}

// MARK: - Plane Anchors

+ (LDNDracoEncoderResult *)encodePlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors {
    return [self encodePlaneAnchors:planeAnchors
                            options:[[LDNDracoEncoderOptions alloc] init]];
}

+ (LDNDracoEncoderResult *)encodePlaneAnchors:(NSArray<ARPlaneAnchor *> *)planeAnchors
                                      options:(LDNDracoEncoderOptions *)options {
    LDNGeometryEnumerator *enumerator = [LDNGeometryEnumerator enumeratorForPlaneAnchors:planeAnchors];
    return [self encodeGeometryEnumerator:enumerator options:options];
}

+ (LDNDracoEncoderResult *)encodeGeometryEnumerator:(LDNGeometryEnumerator *)geometryEnumerator
                                            options:(LDNDracoEncoderOptions *)options {
    LDNLogCreate("Draco Encoder");

    draco::Mesh *mesh = new draco::Mesh();

    LDNSignpostInterval(LDN_INTERVAL_ALLOCATE_MESH, {
        mesh->set_num_points(draco::PointIndex::ValueType([geometryEnumerator totalVertexCount]));
        mesh->SetNumFaces(draco::PointIndex::ValueType([geometryEnumerator totalFaceCount]));
    });

    if (geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationVertex) {
        LDNSignpostInterval(LDN_INTERVAL_ENCODE_VERTICES, {
            draco::GeometryAttribute positionAttribute;
            positionAttribute.Init(draco::GeometryAttribute::POSITION,
                                   nullptr, 3, draco::DT_FLOAT32, false,
                                   draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);

            const int positionAttributeId = mesh->AddAttribute(positionAttribute,
                                                               true, mesh->num_points());

            [geometryEnumerator enumerateVerticesUsingBlock:^(LDNVertexIndex *vertexIndex,
                                                              LDNVertex *vertex) {
                // Must access the attribute by identifier. Otherwise, attribute
                // buffer will be uninitialized.
                draco::AttributeValueIndex attributeValueIndex = draco::AttributeValueIndex(((uint32_t)*vertexIndex));
                mesh->attribute(positionAttributeId)->SetAttributeValue(attributeValueIndex,
                                                                        &(vertex->position));
            }];
        });
    }

    if (geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationFace) {
        LDNSignpostInterval(LDN_INTERVAL_ENCODE_FACES, {
            [geometryEnumerator enumerateFacesUsingBlock:^(LDNFaceIndex *faceIndex,
                                                           LDNFace *face) {
                mesh->SetFace(draco::FaceIndex(((uint32_t)*faceIndex)),
                              draco::Mesh::Face({
                    (draco::PointIndex)face->vertexIndices[0],
                    (draco::PointIndex)face->vertexIndices[1],
                    (draco::PointIndex)face->vertexIndices[2],
                }));
            }];
        });
    }

    // Because we reuse the face to vertex mapping constructed above,
    // classification encoding requires face enumeration.
    if ((geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationClassification) &&
        (geometryEnumerator.supportedEnumerations & LDNGeometryEnumerationFace)) {
        LDNSignpostInterval(LDN_INTERVAL_ENCODE_CLASSIFICATIONS, {
            draco::GeometryAttribute classificationAttribute;
            classificationAttribute.Init(draco::GeometryAttribute::COLOR,
                                         nullptr, 3, draco::DT_UINT8, false,
                                         draco::DataTypeLength(draco::DT_UINT8) * 3, 0);

            const int classificationAttributeId = mesh->AddAttribute(classificationAttribute,
                                                                     true, mesh->num_points());

            [geometryEnumerator enumerateClassificationsUsingBlock:^(LDNClassificationIndex *classificationIndex,
                                                                     LDNClassification *classification) {
                draco::Mesh::Face face = mesh->face((draco::FaceIndex)*classificationIndex);
                LDNSimpleColor classificationColor = [options.classificationColoring colorForMeshClassification:(ARMeshClassification)*classification];

                for (LDNVertexIndex vertexIndex = 0; vertexIndex < 3; vertexIndex++) {
                    // Must access the attribute by identifier. Otherwise,
                    // attribute buffer will be uninitialized.
                    mesh->attribute(classificationAttributeId)->SetAttributeValue(draco::AttributeValueIndex(face[vertexIndex].value()),
                                                                                  &classificationColor);
                }
            }];
        });
    }

    LDNSignpostBegin(LDN_INTERVAL_ENCODE_MESH_BUFFER);

    draco::Encoder encoder;
    draco::EncoderBuffer buffer;

    encoder.SetSpeedOptions(options.encodingSpeed, options.decodingSpeed);

    draco::Status status = encoder.EncodeMeshToBuffer(*mesh, &buffer);
    NSData *data = [NSData dataWithBytes:buffer.buffer()->data()
                                  length:buffer.buffer()->size()];

    delete mesh;

    LDNSignpostEnd(LDN_INTERVAL_ENCODE_MESH_BUFFER);

    return [[LDNDracoEncoderResult alloc] initWithStatus:[[LDNDracoEncoderStatus alloc] initWithStatus:status]
                                                    data:data];
}

@end
