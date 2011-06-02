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
#import "StoresViewController.h"
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
@synthesize selectedButton;
@synthesize selectedViewController;

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10.0f;
    [locationManager startUpdatingLocation];

    self.title = @"Liquor Locator";
    
    // Custom initialization




		    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [locationManager startUpdatingLocation];
    
    [self.selectedViewController viewDidAppear:YES];
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
    
    StoresViewController *controller = [[StoresViewController alloc] initWithNibName:@"StoresView" bundle:nil];
    
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

- (void)dealloc {
    [locationManager release];
    [userLocation release];
    [categoriesButton release];
    [storesButton release];
    [spiritsButton release];
    [localDistillersButton release];
    [selectedButton release];
    [viewControllers release];
    [selectedViewController release];
    [super dealloc];
}

@end
