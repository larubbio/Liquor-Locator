//
//  RootViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "RootViewController.h"
#import "CategoriesViewController.h"
#import "StoresViewController.h"
#import "SearchViewController.h"
#import "LocalDistillersViewController.h"
#import "CampaignViewController.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation RootViewController

@synthesize locationManager;
@synthesize userLocation;

@synthesize viewControllers;
@synthesize tabBar;
@synthesize	categoriesTabBarItem;
@synthesize storesTabBarItem;
@synthesize	spiritsTabBarItem;
@synthesize localDistillersTabBarItem;
@synthesize campaignTabBarItem;
@synthesize selectedTabBarItem;
@synthesize selectedViewController;

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10.0f;
    [locationManager startUpdatingLocation];

    self.title = kCategories;
    
    tabBar.selectedItem = categoriesTabBarItem;	
    
    // Custom initialization
    CategoriesViewController *categoriesTabViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesView" bundle:nil];
    StoresViewController *storesTabViewController = [[StoresViewController alloc] initWithNibName:@"StoresView" bundle:nil];
    SearchViewController *searchTabViewController = [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:nil];
    LocalDistillersViewController *localDistillersTabViewController = [[LocalDistillersViewController alloc] initWithNibName:@"LocalDistillersView" bundle:nil];
    CampaignViewController *campaignTabViewController = [[CampaignViewController alloc] initWithNibName:@"CampaignView" bundle:nil];
		
    NSArray *array = [[NSArray alloc] initWithObjects:categoriesTabViewController, storesTabViewController, searchTabViewController, localDistillersTabViewController, campaignTabViewController, nil];
    self.viewControllers = array;
		
	[categoriesTabViewController viewWillAppear:YES];
	    
    [self.view addSubview:categoriesTabViewController.view];
    self.selectedViewController = categoriesTabViewController;
    self.selectedTabBarItem = categoriesTabBarItem;
//    [self.selectedViewController viewDidAppear:YES];

    [array release];
    [categoriesTabViewController release];
    [storesTabViewController release];
    [searchTabViewController release];
    [localDistillersTabViewController release];
    [campaignTabViewController release];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [locationManager startUpdatingLocation];
    
    [self.selectedViewController viewDidAppear:YES];
}

- (void)dealloc {
    [locationManager release];
    [userLocation release];
    [tabBar release];
    [categoriesTabBarItem release];
    [storesTabBarItem release];
    [spiritsTabBarItem release];
    [localDistillersTabBarItem release];
    [campaignTabBarItem release];
    [selectedTabBarItem release];
    [viewControllers release];
    [selectedViewController release];
    [super dealloc];
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
#pragma mark Tab Bar Deleget Methods
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.selectedTabBarItem) {
        return;
    }
    
#ifdef FLURRY
    [FlurryAPI countPageView];
#endif
        
    UIViewController *controller = nil;
    
	if (item == categoriesTabBarItem) {
		controller = [viewControllers objectAtIndex:0];
        self.title = kCategories;
	} else if (item == storesTabBarItem) {
		controller = [viewControllers objectAtIndex:1];
        self.title = kStores;
	} else if (item == spiritsTabBarItem) {
		controller = [viewControllers objectAtIndex:2];
        self.title = kSearch;
    } else if (item == localDistillersTabBarItem) {
		controller = [viewControllers objectAtIndex:3];
        self.title = kLocalDistillers;
    } else if (item == campaignTabBarItem) {
		controller = [viewControllers objectAtIndex:4];
        self.title = kCampaign;
    }
    
    [controller viewWillAppear:YES];
    [self.selectedViewController viewWillDisappear:YES];
	
    [self.selectedViewController.view removeFromSuperview];
    [self.view addSubview:controller.view];
	
    [self.selectedViewController viewDidDisappear:YES];
    [controller viewDidAppear:YES];
    
    self.selectedViewController = controller;
    self.selectedTabBarItem = item;
}


@end
