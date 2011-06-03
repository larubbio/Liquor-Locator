//
//  RootViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "RootViewController.h"
#import "LiquorLocatorAppDelegate.h"
#import "CategoriesViewController.h"
#import "StoreListViewController.h"
#import "SearchViewController.h"
#import "LocalDistillersViewController.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation RootViewController

@synthesize locationManager;
@synthesize userLocation;

@synthesize viewControllers;
@synthesize	categoriesButton;
@synthesize storesButton;
@synthesize	spiritsButton;
@synthesize localDistillersButton;

@synthesize adBannerView = _adBannerView;
@synthesize adBannerViewIsVisible = _adBannerViewIsVisible;

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10.0f;
    [locationManager startUpdatingLocation];

    self.title = @"Liquor Locator";
    	    
    [self createAdBannerView];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fixupAdView:[UIDevice currentDevice].orientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [locationManager startUpdatingLocation];
    
#ifdef FLURRY
    [FlurryAPI logEvent:@"Dashboard"];        
#endif
}

- (IBAction)viewCategories:(id)sender {
    
    CategoriesViewController *controller = [[CategoriesViewController alloc] initWithNibName:@"CategoriesView" bundle:nil];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

- (IBAction)viewSearch:(id)sender {
    
    SearchViewController *controller = [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:nil];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

- (IBAction)viewStores:(id)sender {
    
    StoreListViewController *controller = [[StoreListViewController alloc] initWithNibName:@"StoreListView" bundle:nil];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

- (IBAction)viewLocal:(id)sender {
    
    LocalDistillersViewController *controller = [[LocalDistillersViewController alloc] initWithNibName:@"LocalDistillersView" bundle:nil];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}


#pragma mark -
#pragma mark Core Location Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.userLocation = newLocation;
//    [locationManager stopUpdatingLocation];
#ifdef FLURRY
    [FlurryAPI setLocation:self.userLocation];
#endif
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

#pragma mark -
#pragma IAd Delegate Methods
- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
                              initWithFrame:CGRectMake(0, self.view.frame.size.height, 0, 0)] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
                                                          ADBannerContentSizeIdentifierPortrait, 
                                                          ADBannerContentSizeIdentifierLandscape, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];            
        }
        [_adBannerView setDelegate:self];
        
        [self.view addSubview:_adBannerView];        
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_adBannerView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        }          
        
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (_adBannerViewIsVisible) {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
            [_adBannerView setFrame:adBannerViewFrame];
        } else {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = self.view.frame.size.height;
            [_adBannerView setFrame:adBannerViewFrame];
        }
        [UIView commitAnimations];
    }   
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_adBannerViewIsVisible) {                
        _adBannerViewIsVisible = YES;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_adBannerViewIsVisible)
    {        
        _adBannerViewIsVisible = NO;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)dealloc {
    [locationManager release];
    [userLocation release];
    [categoriesButton release];
    [storesButton release];
    [spiritsButton release];
    [localDistillersButton release];
    [viewControllers release];

    [super dealloc];
}

@end
