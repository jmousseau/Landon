//
//  LDNProfile.h
//  Landon
//
//  Created by Jack Mousseau on 5/26/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <os/log.h>
#import <os/signpost.h>

// MARK: - Signposts

#define LDNLogCreate(category) \
    os_log_t __ldn_log__ = os_log_create("Landon", category)

#define LDNSignpostBegin(name) \
    os_signpost_id_t __ldn_signpost_id__ = os_signpost_id_generate(__ldn_log__); \
    os_signpost_interval_begin(__ldn_log__, __ldn_signpost_id__, name)

#define LDNSignpostEnd(name) \
    os_signpost_interval_end(__ldn_log__, __ldn_signpost_id__, name)

#define LDNSignpostInterval(name, code) \
    { \
        LDNSignpostBegin(name); \
        code \
        LDNSignpostEnd(name); \
    } \

// MARK: - Intervals

#define LDN_INTERVAL_ALLOCATE_MESH "Allocate Mesh"
#define LDN_INTERVAL_ENCODE_CLASSIFICATIONS "Encode Classifications"
#define LDN_INTERVAL_ENCODE_FACES "Encode Faces"
#define LDN_INTERVAL_ENCODE_MESH_BUFFER "Encode Mesh Buffer"
#define LDN_INTERVAL_ENCODE_NORMALS "Encode Normals"
#define LDN_INTERVAL_ENCODE_VERTICES "Encode Vertices"
