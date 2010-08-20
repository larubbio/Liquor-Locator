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

@synthesize dataCache;
#define SPLASH
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    dataCache = [[NSMutableDictionary alloc] init];
    
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

- (id)getCachedDataForKey:(NSString *)key {
    return [dataCache objectForKey:key];
}

- (void)putCachedData:(id)data forKey:(NSString *)key {
    [dataCache setObject:data forKey:key];
}
     
- (void)purgeCache {
    [dataCache removeAllObjects];
}

-(void)getInitialData:(id)obj {
    [NSThread sleepForTimeInterval:3.0]; // simulate waiting for server response
    [splashView removeFromSuperview];
    [window addSubview:navController.view];
}

- (void)dealloc {
    [dataCache release];
    [navController release];
    [window release];
    [super dealloc];
}

@end
