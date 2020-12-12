//
//  LDNGeometryEnumerator.h
//  Landon
//
//  Created by Jack Mousseau on 11/30/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <Foundation/Foundation.h>
#import <simd/simd.h>

/// The integer type used by Landon.
typedef uint32_t LDNInteger;

// MARK: - Enumerations

/// Geometry enumerations.
///
/// - LDNGeometryEnumerationVertex: Vertex enumeration.
/// - LDNGeometryEnumerationFace: Face enumeration.
/// - LDNGeometryEnumerationNormal: Normal enumeration.
typedef NS_OPTIONS(NSUInteger, LDNGeometryEnumeration) {
    LDNGeometryEnumerationNone = (0 << 0),
    LDNGeometryEnumerationVertex = (1 << 0),
    LDNGeometryEnumerationFace = (1 << 1),
    LDNGeometryEnumerationNormal = (1 << 2),
};

// MARK: - Vertex

/// A vertex index.
typedef LDNInteger LDNVertexIndex;

/// A vertex.
typedef struct LDNVertex {

    /// The vertex's position.
    simd_float4 position;

} LDNVertex;

/// A vertex enumeration block.
///
/// @param vertexIndex A pointer to the current vertex index.
/// @param vertex A pointer to the current vertex.
typedef void (^LDNVertexEnumerationBlock)(LDNVertexIndex * _Nonnull vertexIndex,
                                          LDNVertex * _Nonnull vertex);

// MARK: - Face

/// A face index.
typedef LDNInteger LDNFaceIndex;

/// A face.
typedef struct LDNFace {

    /// The face's vertex indices
    LDNVertexIndex vertexIndices[3];

} LDNFace;

/// A face enumeration block.
///
/// @param faceIndex A pointer to the current face index.
/// @param face A pointer to the current face.
typedef void (^LDNFaceEnumerationBlock)(LDNFaceIndex * _Nonnull faceIndex,
                                        LDNFace * _Nonnull face);

// MARK: - Normal

/// A normal index.
typedef LDNInteger LDNNormalIndex;

// A normal.
typedef simd_float3 LDNNormal;

/// A normal enumeration block.
///
/// @param normalIndex A pointer to the current normal index.
/// @param normal A pointer to the current normal.
typedef void (^LDNNormalEnumerationBlock)(LDNNormalIndex * _Nonnull normalIndex,
                                          LDNNormal * _Nonnull normal);

// MARK: - Enumerator

/// A geometry enumerator.
@interface LDNGeometryEnumerator : NSObject

/// Initialize a geometry enumerator for a given face anchor set.
///
/// @param faceAnchors The face anchors whose geometry to enumerate.
/// @return A new geometry
+ (nonnull LDNGeometryEnumerator *)enumeratorForFaceAnchors:(nonnull NSArray<ARFaceAnchor *> *)faceAnchors;

/// Initialize a geometry enumerator for a given mesh anchor set.
///
/// @param meshAnchors The mesh anchors whose geometry to enumerate.
/// @return A new geometry
+ (nonnull LDNGeometryEnumerator *)enumeratorForMeshAnchors:(nonnull NSArray<ARMeshAnchor *> *)meshAnchors;

/// Initialize a geometry enumerator for a given plane anchor set.
///
/// @param planeAnchors The plane anchors whose geometry to enumerate.
/// @return A new geometry enumerator instance.
+ (nonnull LDNGeometryEnumerator *)enumeratorForPlaneAnchors:(nonnull NSArray<ARPlaneAnchor *> *)planeAnchors;

/// The enumerations supported by the geometry enumerator.
@property (nonatomic, readonly) LDNGeometryEnumeration supportedEnumerations;

/**
 The geometry enumerator's total number of vertices.
 */
- (LDNInteger)totalVertexCount;

/**
 The geometry enumerator's total number of faces.
 */
- (LDNInteger)totalFaceCount;

/// Enumerate the geometry's vertices using a given vertex enumeration block.
///
/// @param block The vertex enumeration block.
- (void)enumerateVerticesUsingBlock:(nonnull LDNVertexEnumerationBlock)block;

/// Enumerate the geometry's faces using a given face enumeration block.
///
/// @param block The face enumeration block.
- (void)enumerateFacesUsingBlock:(nonnull LDNFaceEnumerationBlock)block;

/// Enumerate the geometry's normals using a given normal enumeration block.
///
/// @param block The normal enumeration block.
- (void)enumerateNormalsUsingBlock:(nonnull LDNNormalEnumerationBlock)block;

@end
