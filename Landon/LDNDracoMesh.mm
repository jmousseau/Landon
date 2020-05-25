//
//  LDNDracoMesh.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "draco/mesh/mesh.h"
#import "LDNDracoEncoder.h"
#import "LDNDracoMesh.h"

/// A Draco mesh.
@interface LDNDracoMesh ()

/// The Draco mesh's backing mesh.
@property (nonatomic) std::shared_ptr<draco::Mesh> mesh;

@end

@implementation LDNDracoMesh

- (instancetype)initWithMeshGeometry:(ARMeshGeometry *)meshGeometry {
    if (self = [super init]) {
        _mesh = std::make_shared<draco::Mesh>();

        // Vertices
        {
            ARGeometrySource *vertices = meshGeometry.vertices;

            self.mesh->set_num_points(draco::PointIndex::ValueType(vertices.count));

            NSData *vertexData = [NSData dataWithBytes:vertices.buffer.contents
                                                length:vertices.buffer.length];

            draco::GeometryAttribute vertexPostionAttribute;
            vertexPostionAttribute.Init(draco::GeometryAttribute::POSITION,
                                        nullptr, 3, draco::DT_FLOAT32, false,
                                        draco::DataTypeLength(draco::DT_FLOAT32) * 3, 0);

            const int attributeId = self.mesh->AddAttribute(vertexPostionAttribute, true, self.mesh->num_points());

            std::vector<float32_t> vertex(3);
            for (uint32_t vertexAttributeIndex = 0;
                 vertexAttributeIndex < self.mesh->num_points();
                 vertexAttributeIndex++) {
                [vertexData getBytes:vertex.data()
                               range:NSMakeRange(vertexAttributeIndex * vertices.stride + vertices.offset,
                                                 vertices.stride)];

                // Must access the attribute by identifier. Otherwise, attribute
                // buffer will be uninitialized.
                self.mesh->attribute(attributeId)->SetAttributeValue(draco::AttributeValueIndex(vertexAttributeIndex),
                                                                     vertex.data());
            }
        }

        // Faces
        {
            ARGeometryElement *faces = meshGeometry.faces;

            self.mesh->SetNumFaces(faces.count);


            NSData *faceData = [NSData dataWithBytes:faces.buffer.contents
                                              length:faces.buffer.length];

            draco::Mesh::Face face;
            NSUInteger faceStride = 3 * faces.bytesPerIndex;

            for (draco::FaceIndex faceIndex = draco::FaceIndex(0);
                 faceIndex < self.mesh->num_faces();
                 faceIndex++) {
                [faceData getBytes:face.data()
                             range:NSMakeRange(faceIndex.value() * faceStride, faceStride)];
                self.mesh->SetFace(faceIndex, face);
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.mesh.reset();
}

- (LDNDracoEncoderResult *)encode {
    return [LDNDracoEncoder encodeMesh:self];
}

@end
