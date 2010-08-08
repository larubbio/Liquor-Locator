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
@synthesize splashView;

#define SPLASH
- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
#ifdef SPLASH
    [window addSubview:navController.view];
    [window makeKeyAndVisible];    
#else
    [window addSubview:splashView];
    [NSThread detachNewThreadSelector:@selector(getInitialData:) 
                             toTarget:self withObject:nil];
#endif    

}

-(void)getInitialData:(id)obj {
    [NSThread sleepForTimeInterval:3.0]; // simulate waiting for server response
    [splashView removeFromSuperview];
    [window addSubview:navController.view];
}

- (void)dealloc {
    [navController release];
    [window release];
    [super dealloc];
}

@end
