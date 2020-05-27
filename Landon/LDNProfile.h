//
//  LDNProfile.h
//  Landon
//
//  Created by Jack Mousseau on 5/26/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <os/log.h>
#import <os/signpost.h>

#define LDNLogCreate(category) \
    os_log_t __ldn_log__ = os_log_create("Landon", category)

#define LDNSignpostBegin(name) \
    os_signpost_id_t __ldn_signpost_id__ = os_signpost_id_generate(__ldn_log__); \
    os_signpost_interval_begin(__ldn_log__, __ldn_signpost_id__, name)

#define LDNSignpostEnd(name) \
    os_signpost_interval_end(__ldn_log__, __ldn_signpost_id__, name)
