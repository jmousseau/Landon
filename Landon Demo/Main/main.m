//
//  main.m
//  Landon
//
//  Created by Jack Mousseau on 5/24/20.
//  Copyright © 2020 Jack Mousseau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LNDAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString *appDelegateClassName;

    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([LNDAppDelegate class]);
    }

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
