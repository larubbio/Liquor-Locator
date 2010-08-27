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

#import "Constants.h"

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
    
    NSString *title = kMap;
    if (table.hidden) {
        title = kList;
    }
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(toggleView:)];
    
    if (delegate.navController.topViewController == self) {
        self.navigationItem.rightBarButtonItem = barBtn;
    } else {
        rootView.navigationItem.rightBarButtonItem = barBtn;
    }

    [barBtn release];
}    

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];

    if (delegate.navController.topViewController == self) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        rootView.navigationItem.rightBarButtonItem = nil;
    }
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
    
    if ([barBtn.title isEqualToString:kMap]) {
        barBtn.title = kList;
        map.hidden = NO;
        table.hidden = YES;
    } else {
        barBtn.title = kMap;
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
    if ([dict objectForKey:kStore]) {
        store = [dict objectForKey:kStore];
    } else {
        store = dict;
    }
    
    StoreDetailViewController *storeDetailViewController = [[StoreDetailViewController alloc] initWithNibName:@"StoreDetailView" bundle:nil];
    storeDetailViewController.storeId = [((NSString *)[store objectForKey:kId]) intValue];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [self viewWillDisappear:YES];
    
    [delegate.navController pushViewController:storeDetailViewController animated:YES];
    
    [self viewDidDisappear:YES];
    
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
    if ([dict objectForKey:kStore]) {
        store = [dict objectForKey:kStore];
    } else {
        store = dict;
    }
    cell.textLabel.text = [store objectForKey:kName];
    
    NSString *detail = nil;
    if ([store objectForKey:kDist]) {
        if ([store objectForKey:kQty]) {
            detail = [NSString stringWithFormat:@"%.2f miles %d In Stock", [((NSDecimalNumber *)[store objectForKey:kDist]) doubleValue],
                                                                           [((NSDecimalNumber *)[store objectForKey:kQty]) integerValue]];
        } else {
            detail = [NSString stringWithFormat:@"%.2f miles", [((NSDecimalNumber *)[store objectForKey:kDist]) doubleValue]];
        }
    } else if ([store objectForKey:kQty]) {
        detail = [NSString stringWithFormat:@"%d In Stock", [((NSDecimalNumber *)[store objectForKey:kQty]) integerValue]];
    }
    
    if (detail != nil) {
        cell.detailTextLabel.text = detail;
    }
    
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
        
        if ([dict objectForKey:kStore]) {
            store = [dict objectForKey:kStore];
            [store setObject:[dict objectForKey:kQty] forKey:kQty];
        } else {
            store = dict;
        }
        
        StoreAnnotation *anno = [[StoreAnnotation alloc] init];
        anno.name = [store objectForKey:kName];
        anno.address = [store objectForKey:kAddress];
        anno.storeId = [((NSString *)[store objectForKey:kId]) intValue];
        anno.latitude = [((NSString *)[store objectForKey:kLat]) doubleValue];
        anno.longitude = [((NSString *)[store objectForKey:kLong]) doubleValue];
        
        // Compute distance
        LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];
        
        if (rootView.userLocation != nil) {
            double latitude = [[store objectForKey:kLat] doubleValue];
            double longitude = [[store objectForKey:kLong] doubleValue];
            CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            CLLocationDistance distance;
            
            if ([storeLocation respondsToSelector:@selector(distanceFromLocation:)]) {
                distance = [storeLocation distanceFromLocation:rootView.userLocation];
            } else {
                distance = [storeLocation getDistanceFrom:rootView.userLocation];
            }
            double miles = distance * 0.000621371192;

            NSDecimalNumber *dist = [[NSDecimalNumber alloc] initWithDouble:miles];
            [store setObject:dist forKey:kDist];

            [storeLocation release];
            [dist release];
        }
        
        [tmpData addObject:store];
        
        [map addAnnotation:anno];
        
        [anno release];
    }

    NSSortDescriptor *distDescriptor =
    [[[NSSortDescriptor alloc] initWithKey:kDist
                                 ascending:YES
                                  selector:@selector(compare:)] autorelease];
    
    NSArray *descriptors = [NSArray arrayWithObjects:distDescriptor, nil];
    self.tableData = [tmpData sortedArrayUsingDescriptors:descriptors];
    
    [tmpData release];
    [table reloadData];
}

#pragma mark -
#pragma mark Map View Delegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView;
    
    pinView = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:@"annoView"];
    
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop=NO;
        pinView.canShowCallout = YES;

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    }    

    return pinView; 
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    StoreDetailViewController *storeDetailViewController = [[StoreDetailViewController alloc] initWithNibName:@"StoreDetailView" bundle:nil];
    storeDetailViewController.storeId = ((StoreAnnotation *)view.annotation).storeId;
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:storeDetailViewController animated:YES];
    
    [storeDetailViewController release];
}

@end
