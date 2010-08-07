//
//  StoreList.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/7/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreList.h"
#import "StoreDetailViewController.h"
#import "StoreAnnotation.h"
#import "LiquorLocatorAppDelegate.h"
#import "RootViewController.h"


@implementation StoreList

@synthesize table;
@synthesize map;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];
    
    MKCoordinateRegion region;
    region.center = rootView.userLocation.coordinate;
    MKCoordinateSpan span = {0.5, 0.5};
    region.span = span;
    map.region = region;   
    
    NSString *title = @"Map";
    if (table.hidden) {
        title = @"List";
    }
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(toggleView:)];
    
    self.navigationItem.rightBarButtonItem = barBtn;
    
    [barBtn release];
}    

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [table release];
    [map release];
    [super dealloc];
}

#pragma mark -
- (void)toggleView:(id)sender {
    UIBarButtonItem *barBtn = sender;
    
    if ([barBtn.title isEqualToString:@"Map"]) {
        barBtn.title = @"List";
        map.hidden = NO;
        table.hidden = YES;
    } else {
        barBtn.title = @"Map";
        map.hidden = YES;
        table.hidden = NO;
    }        
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSDictionary *dict = [objectList objectAtIndex:row];
    NSDictionary *store;
    
    // This branch is for handling the different JSON between a store list and store inv list
    if ([dict objectForKey:@"store"]) {
        store = [dict objectForKey:@"store"];
    } else {
        store = dict;
    }
    
    StoreDetailViewController *storeDetailViewController = [[StoreDetailViewController alloc] initWithNibName:@"StoreDetailView" bundle:nil];
    storeDetailViewController.storeId = [((NSString *)[store objectForKey:@"id"]) intValue];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:storeDetailViewController animated:YES];
    
    [storeDetailViewController release];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StoreTableIdentifier = @"StoreTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StoreTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StoreTableIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *dict = [objectList objectAtIndex:row];
    NSDictionary *store;

    // This branch is for handling the different JSON between a store list and store inv list
    if ([dict objectForKey:@"store"]) {
        store = [dict objectForKey:@"store"];
    } else {
        store = dict;
    }
    cell.textLabel.text = [store objectForKey:@"name"];
    
    // Compute distance
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];
    
    double latitude = [[store objectForKey:@"lat"] doubleValue];
    double longitude = [[store objectForKey:@"long"] doubleValue];
    CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocationDistance distance = [storeLocation distanceFromLocation:rootView.userLocation];
    double miles = distance * 0.000621371192;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f miles", miles];
    
    [storeLocation release];
    return cell;
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    // Create all my annotations and add to map
    for (NSDictionary *dict in self.objectList) {
        NSDictionary *store;
        
        if ([dict objectForKey:@"store"]) {
            store = [dict objectForKey:@"store"];
        } else {
            store = dict;
        }
        
        StoreAnnotation *anno = [[StoreAnnotation alloc] init];
        anno.name = [store objectForKey:@"name"];
        anno.address = [store objectForKey:@"address"];
        anno.latitude = [((NSString *)[store objectForKey:@"lat"]) doubleValue];
        anno.longitude = [((NSString *)[store objectForKey:@"long"]) doubleValue];
        
        [map addAnnotation:anno];
        
        [anno release];
    }
    
    [table reloadData];
}

@end
