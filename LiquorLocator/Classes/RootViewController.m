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
#import "CampaignViewController.h"

@implementation RootViewController

@synthesize locationManager;
@synthesize userLocation;

@synthesize viewControllers;
@synthesize tabBar;
@synthesize	categoriesTabBarItem;
@synthesize storesTabBarItem;
@synthesize	spiritsTabBarItem;
@synthesize campaignTabBarItem;
@synthesize selectedViewController;

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10.0f;
    [locationManager startUpdatingLocation];

    self.title = @"Categories";
    
    tabBar.selectedItem = categoriesTabBarItem;	
    
    // Custom initialization
    CategoriesViewController *categoriesTabViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesView" bundle:nil];
    StoresViewController *storesTabViewController = [[StoresViewController alloc] initWithNibName:@"StoresView" bundle:nil];
    SearchViewController *searchTabViewController = [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:nil];
    CampaignViewController *campaignTabViewController = [[CampaignViewController alloc] initWithNibName:@"CampaignView" bundle:nil];
		
    NSArray *array = [[NSArray alloc] initWithObjects:categoriesTabViewController, storesTabViewController, searchTabViewController, campaignTabViewController, nil];
    self.viewControllers = array;
		
	[categoriesTabViewController viewWillAppear:YES];
	    
    [self.view addSubview:categoriesTabViewController.view];
    self.selectedViewController = categoriesTabViewController;

    [self.selectedViewController viewDidAppear:YES];

    [array release];
    [categoriesTabViewController release];
    [storesTabViewController release];
    [searchTabViewController release];
    [campaignTabViewController release];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [locationManager release];
    [userLocation release];
    [tabBar release];
    [categoriesTabBarItem release];
    [storesTabBarItem release];
    [spiritsTabBarItem release];
    [campaignTabBarItem release];
    [viewControllers release];
    [selectedViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Core Location Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.userLocation = newLocation;
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

#pragma mark -
#pragma mark Tab Bar Deleget Methods
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UIViewController *controller = nil;
    
	if (item == categoriesTabBarItem) {
		controller = [viewControllers objectAtIndex:0];
        self.title = @"Categories";
	} else if (item == storesTabBarItem) {
		controller = [viewControllers objectAtIndex:1];
        self.title = @"Stores";
	} else if (item == spiritsTabBarItem) {
		controller = [viewControllers objectAtIndex:2];
        self.title = @"Spirits";
    } else if (item == campaignTabBarItem) {
		controller = [viewControllers objectAtIndex:3];
        self.title = @"Campaign";
    }
    
	[controller viewWillAppear:YES];
	[self.selectedViewController viewWillDisappear:YES];
	
    [self.selectedViewController.view removeFromSuperview];
    [self.view addSubview:controller.view];
	
	[self.selectedViewController viewDidDisappear:YES];
	[controller viewDidAppear:YES];
    
    self.selectedViewController = controller;
}


@end
