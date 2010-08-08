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

@synthesize tableData;

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
    [tableData release];
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
    NSDictionary *dict = [tableData objectAtIndex:row];
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
    return [self.tableData count];
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
    NSDictionary *dict = [tableData objectAtIndex:row];
    NSDictionary *store;

    // This branch is for handling the different JSON between a store list and store inv list
    if ([dict objectForKey:@"store"]) {
        store = [dict objectForKey:@"store"];
    } else {
        store = dict;
    }
    cell.textLabel.text = [store objectForKey:@"name"];
    
    NSString *detail;
    if ([store objectForKey:@"qty"]) {
        detail = [NSString stringWithFormat:@"%.2f miles %d In Stock", [((NSDecimalNumber *)[store objectForKey:@"dist"]) doubleValue],
                                                                       [((NSDecimalNumber *)[store objectForKey:@"qty"]) integerValue]];
    } else {
        detail = [NSString stringWithFormat:@"%.2f miles", [((NSDecimalNumber *)[store objectForKey:@"dist"]) doubleValue]];
    }
    cell.detailTextLabel.text = detail;
    
    return cell;
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    NSMutableArray *tmpData = [[NSMutableArray alloc] init];
    
    // Create all my annotations and add to map
    // I'll also munge the returned json so both store inventory and store list json look the same
    for (NSMutableDictionary *dict in self.objectList) {
        NSMutableDictionary *store;
        
        if ([dict objectForKey:@"store"]) {
            store = [dict objectForKey:@"store"];
            [store setObject:[dict objectForKey:@"qty"] forKey:@"qty"];
        } else {
            store = dict;
        }
        
        StoreAnnotation *anno = [[StoreAnnotation alloc] init];
        anno.name = [store objectForKey:@"name"];
        anno.address = [store objectForKey:@"address"];
        anno.latitude = [((NSString *)[store objectForKey:@"lat"]) doubleValue];
        anno.longitude = [((NSString *)[store objectForKey:@"long"]) doubleValue];
        
        // Compute distance
        LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];
        
        double latitude = [[store objectForKey:@"lat"] doubleValue];
        double longitude = [[store objectForKey:@"long"] doubleValue];
        CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationDistance distance = [storeLocation distanceFromLocation:rootView.userLocation];
        double miles = distance * 0.000621371192;

        NSDecimalNumber *dist = [[NSDecimalNumber alloc] initWithDouble:miles];
        [store setObject:dist forKey:@"dist"];
        
        [tmpData addObject:store];
        
        [map addAnnotation:anno];
        
        [anno release];
        [storeLocation release];
        [dist release];
    }

    NSSortDescriptor *distDescriptor =
    [[[NSSortDescriptor alloc] initWithKey:@"dist"
                                 ascending:YES
                                  selector:@selector(compare:)] autorelease];
    
    NSArray *descriptors = [NSArray arrayWithObjects:distDescriptor, nil];
    self.tableData = [tmpData sortedArrayUsingDescriptors:descriptors];
    
    [tmpData release];
    [table reloadData];
}

@end
