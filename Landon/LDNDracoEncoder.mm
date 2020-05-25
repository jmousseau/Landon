//
//  LDNDracoEncoder.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "draco/compression/encode.h"
#import "draco/mesh/mesh.h"
#import "LDNDracoEncoder.h"
#import "LDNDracoEncoderResult+Private.h"
#import "LDNDracoEncoderStatus+Private.h"

@implementation LDNDracoEncoder

+ (LDNDracoEncoderResult *)encodeMeshAnchors:(NSArray<ARMeshAnchor *> *)meshAnchors {
    draco::Mesh mesh;

    // Allocate space for vertices and faces.
    {
        uint32_t vertexCount = 0;
        uint32_t faceCount = 0;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            vertexCount += meshAnchor.geometry.vertices.count;
            faceCount += meshAnchor.geometry.faces.count;
        }

        mesh.set_num_points(draco::PointIndex::ValueType(vertexCount));
        mesh.SetNumFaces(draco::PointIndex::ValueType(faceCount));
    }


    // Encode vertices.
    {
        uint32_t encodedVertexCount = 0;

        draco::GeometryAttribute positionAttribute;
        positionAttribute.Init(draco::GeometryAttribute::POSITION,
                               nullptr, 3, draco::DT_FLOAT32, false,
                               draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);


        const int positionAttributeId = mesh.AddAttribute(positionAttribute,
                                                          true, mesh.num_points());

        std::vector<float32_t> vertex(3);

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometrySource *vertices = meshAnchor.geometry.vertices;
            NSData *vertexData = [NSData dataWithBytes:vertices.buffer.contents
                                                length:vertices.buffer.length];

            for (uint32_t vertexAttributeIndex = 0;
                 vertexAttributeIndex < vertices.count;
                 vertexAttributeIndex++) {
                [vertexData getBytes:vertex.data()
                               range:NSMakeRange(vertexAttributeIndex * vertices.stride + vertices.offset,
                                                 vertices.stride)];

                // Must access the attribute by identifier. Otherwise, attribute
                // buffer will be uninitialized.
                uint32_t offsetVertexAttributeIndex = vertexAttributeIndex + encodedVertexCount;
                mesh.attribute(positionAttributeId)->SetAttributeValue(draco::AttributeValueIndex(offsetVertexAttributeIndex),
                                                                       vertex.data());
            }

            encodedVertexCount += vertices.count;
        }
    }

    // Encode faces.
    {
        uint32_t encodedFaceCount = 0;

        draco::Mesh::Face face;

        for (ARMeshAnchor *meshAnchor in meshAnchors) {
            ARGeometryElement *faces = meshAnchor.geometry.faces;
            NSData *faceData = [NSData dataWithBytes:faces.buffer.contents
                                                length:faces.buffer.length];
            uint64_t faceStride = 3 * faces.bytesPerIndex;

            for (draco::FaceIndex faceIndex = draco::FaceIndex(0);
                 faceIndex < (uint32_t)faces.count;
                 faceIndex++) {
                 [faceData getBytes:face.data()
                              range:NSMakeRange(faceIndex.value() * faceStride, faceStride)];
                 mesh.SetFace(faceIndex + encodedFaceCount, face);
             }

            encodedFaceCount += faces.count;
        }
    }


    draco::Encoder encoder;
    draco::EncoderBuffer buffer;

    encoder.SetSpeedOptions(5, 5);

    draco::Status status = encoder.EncodeMeshToBuffer(mesh, &buffer);
    NSData *data = [NSData dataWithBytes:buffer.buffer()->data()
                                  length:buffer.buffer()->size()];

    return [[LDNDracoEncoderResult alloc] initWithStatus:[[LDNDracoEncoderStatus alloc] initWithStatus:status]
                                                    data:data];
}

@end
