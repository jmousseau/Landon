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

// MARK: - Enumerations

/// Geometry enumerations.
///
/// - LDNGeometryEnumerationFace: Face enumeration.
/// - LDNGeometryEnumerationVertex: Vertex enumeration.
typedef NS_OPTIONS(NSUInteger, LDNGeometryEnumeration) {
    LDNGeometryEnumerationNone = (0 << 0),
    LDNGeometryEnumerationFace = (1 << 0),
    LDNGeometryEnumerationVertex = (1 << 1),
};

// MARK: - Vertex

/// A vertex index.
typedef NSUInteger LDNVertexIndex;

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
typedef NSUInteger LDNFaceIndex;

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
 Enumerate the geometry's vertices using a given vertex enumeration block.

 @param block The vertex enumeration block.
 */
- (void)enumerateVerticesUsingBlock:(nonnull LDNVertexEnumerationBlock)block;

/// Enumerate the geometry's face's using a given face enumeration block.
///
/// @param block The face enumeration block.
- (void)enumerateFacesUsingBlock:(nonnull LDNFaceEnumerationBlock)block;

@end
