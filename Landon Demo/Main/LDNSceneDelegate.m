//
//  LDNSceneDelegate.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import "LDNSceneDelegate.h"

@implementation LDNSceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    self.window.rootViewController = [[UIViewController alloc] init];
}

@end
