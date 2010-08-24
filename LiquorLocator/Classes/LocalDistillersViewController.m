//
//  LocalDistillersViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/22/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "LocalDistillersViewController.h"
#import "LiquorLocatorAppDelegate.h"

#import "BlurbViewCell.h"

@implementation LocalDistillersViewController

@synthesize table;
@synthesize distillers;

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = @"http://wsll.pugdogdev.com/distillers";
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [distillers release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        NSArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:section]];
        
        return [list count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Washington State Distillers";
    } else if (section == 1) {
        return @"With Inventory in Stores";
    } else if (section == 2) {
        return @"Not Yet in Stores";
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BlurbCellIdentifier = @"BlurbCellIdentifier";
    static NSString *LocalDistillerTableIdentifier = @"LocalDistillerTableIdentifier";
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell;
    
    if (section == 0) {
        BlurbViewCell *cell = (BlurbViewCell *)[tableView dequeueReusableCellWithIdentifier:BlurbCellIdentifier];
        if ( cell == nil ) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BlurbCell" owner:self options:nil];
            id firstObject = [topLevelObjects objectAtIndex:0];
            if ( [ firstObject isKindOfClass:[UITableViewCell class]] )
                cell = firstObject;     
            else {
                cell = [topLevelObjects objectAtIndex:1];
            }
        }

        [cell.webView loadHTMLString:@"<b>Describe</b> Distillers" baseURL:nil];
    } else if (section == 1 || section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:LocalDistillerTableIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LocalDistillerTableIdentifier] autorelease];
        }
        
        NSArray *distillersSection = [distillers objectForKey:[NSNumber numberWithInt:section]];
        NSMutableDictionary *distiller = [distillersSection objectAtIndex:row];
        cell.textLabel.text = [distiller objectForKey:@"name"];
        
        if (section == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }            
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
/*
    DistillerDetailViewController *controller;
    
    NSUInteger section = [indexPath section];
    if (section != 1) {
        return nil;
    }
    
    NSUInteger row = [indexPath row];
    
    NSArray *distillerSection = [self.distillers objectForKey:[NSNumber numberWithInt:row]];
    NSDictionary *distiller = [distillerSection objectAtIndex:row]; 
    
    controller = [[DistillerDetailViewController alloc] initWithNibName:@"DistillerDetailView" bundle:nil];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
 */
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    if (distillers != nil) {
        [distillers release];
        distillers = nil;
    }
    distillers = [[NSMutableDictionary alloc] init];
    NSMutableArray *selling = [[NSMutableArray alloc] init];
    NSMutableArray *website_only = [[NSMutableArray alloc] init];
    
    [distillers setObject:selling forKey:[NSNumber numberWithInt:1]];
    [distillers setObject:website_only forKey:[NSNumber numberWithInt:2]];
    
    // Loop over objects
    for (NSMutableDictionary *d in objects) {
        BOOL in_store = [((NSString *)[d objectForKey:@"in_store"]) boolValue];
        
        if (in_store == YES) {
            NSMutableArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:1]];
            [list addObject:d];
        } else {
            NSMutableArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:2]];
            [list addObject:d];
        }
    }
    
    [selling release];
    [website_only release];
    
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}

@end
