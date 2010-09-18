//
//  LiquorLocatorAppDelegate.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright Pug Dog Dev LLC 2010. All rights reserved.
//

#import "LiquorLocatorAppDelegate.h"
#import "RootViewController.h"
#import "FlurryAPI.h"

@implementation LiquorLocatorAppDelegate

@synthesize window;

@synthesize navController;
@synthesize splashView;

@synthesize dataCache;

void uncaughtExceptionHandler(NSException *exception) {
#ifdef FLURRY
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
#endif
}

#pragma mark UIApplication Delegate Methods
- (void)applicationDidFinishLaunching:(UIApplication *)application { 
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
#ifdef FLURRY
    [FlurryAPI setAppVersion:@"1.0"];
//    [FlurryAPI startSession:@"FRBRP3NZIFW8FLSY7DW4"]; // Development
    [FlurryAPI startSession:@"L4AWJM8QPWPN3C1EK8K9"]; // Production
    
    [FlurryAPI countPageViews:navController];
#endif
    
    dataCache = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];  
    [dateFormat release];
    
    [self putCachedData:dateStr forKey:@"DATE"];
    
    // Override point for customization after application launch
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    [window addSubview:splashView];
    [window addSubview:navController.view];
    [window bringSubviewToFront:splashView];
    [window makeKeyAndVisible];    
    
    [self performSelector:@selector(removeSplash) withObject:nil afterDelay:3.0];
}

-(void)removeSplash;
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    
    navController.view.frame = [[UIScreen mainScreen] applicationFrame];    
    
    [splashView removeFromSuperview];
    [splashView release];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Check cache date.  If older than 1 week purge and reset date
    
    NSString *dateStr = [self getCachedDataForKey:@"DATE"];
    
    if (dateStr != nil) {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSDate *cacheDate = [dateFormat dateFromString:dateStr];
        [dateFormat release];
        
        NSDate *today =[NSDate date];
        
        if ([cacheDate timeIntervalSinceDate:today] > 7) {
            [self purgeCache];
        }        
    } else {
        // Cache has no date, add one
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];  
        [dateFormat release];
        
        [self putCachedData:dateStr forKey:@"DATE"];
    }        
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [self purgeCache];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark -
- (id)getCachedDataForKey:(NSString *)key {
    return [dataCache objectForKey:key];
}

- (void)putCachedData:(id)data forKey:(NSString *)key {
    if (data != nil) {        
        [dataCache setObject:data forKey:key];
    }
}
     
- (void)purgeCache {
    [dataCache removeAllObjects];
}

- (void)dealloc {
    [dataCache release];
    [navController release];
    [window release];
    [super dealloc];
}

@end
