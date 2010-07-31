//
//  LiquorLocatorAppDelegate.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright Pug Dog Dev LLC 2010. All rights reserved.
//

#import "LiquorLocatorAppDelegate.h"
#import "RootViewController.h"

@implementation LiquorLocatorAppDelegate

@synthesize window;
@synthesize navController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    
    [window addSubview:navController.view];
    [window makeKeyAndVisible];    
}


- (void)dealloc {
    [navController release];
    [window release];
    [super dealloc];
}


@end
