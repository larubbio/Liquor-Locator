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

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window addSubview:navController.view];
    [window makeKeyAndVisible];    

/*    [window addSubview:splashView];
    [window makeKeyAndVisible];    
    [NSThread detachNewThreadSelector:@selector(getInitialData:) 
                             toTarget:self withObject:nil];
*/    

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
