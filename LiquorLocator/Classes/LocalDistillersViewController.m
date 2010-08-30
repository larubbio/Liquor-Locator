//
//  LocalDistillersViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/22/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "LocalDistillersViewController.h"
#import "DistillerDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

#import "BlurbViewCell.h"

#import "Constants.h"
#import "FlurryAPI.h"

#ifdef SHOW_BLURB
#define BLURB_SECTION 0
#define WITH_INVENTORY 1
#define WEBSITE_ONLY 2
#else
#define BLURB_SECTION -1
#define WITH_INVENTORY 0
#define WEBSITE_ONLY 1
#endif
@implementation LocalDistillersViewController

@synthesize table;
@synthesize distillers;

@synthesize blurbCell;

- (void)viewDidAppear:(BOOL)animated {
    [FlurryAPI logEvent:@"DistillersView"];

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
    [blurbCell release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef SHOW_BLURB
    return 3;
#else
    return 2;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == BLURB_SECTION) {
        return 1;
    } else {
        NSArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:section]];
        
        return [list count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == BLURB_SECTION) {
        return @"Washington State Distillers";
    } else if (section == WITH_INVENTORY) {
        return @"With Inventory in Stores";
    } else if (section == WEBSITE_ONLY) {
        return @"Not Yet in Stores";
    }
    
    return nil;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSUInteger section = [indexPath section];
    if (section == BLURB_SECTION) {
        return 105;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BlurbCellIdentifier = @"BlurbCellIdentifier";
    static NSString *LocalDistillerTableIdentifier = @"LocalDistillerTableIdentifier";
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell;
    
    if (section == BLURB_SECTION) {
        BlurbViewCell *bc = (BlurbViewCell *)[tableView dequeueReusableCellWithIdentifier:BlurbCellIdentifier];
        if ( bc == nil ) {
            [[NSBundle mainBundle] loadNibNamed:@"BlurbCell" owner:self options:nil];
            bc = self.blurbCell;
        }

        [bc.webView loadHTMLString:@"<b>Describe</b> Distillers" baseURL:nil];
        
        cell = bc;
    } else if (section == WITH_INVENTORY || section == WEBSITE_ONLY) {
        cell = [tableView dequeueReusableCellWithIdentifier:LocalDistillerTableIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LocalDistillerTableIdentifier] autorelease];
        }
        
        NSArray *distillersSection = [distillers objectForKey:[NSNumber numberWithInt:section]];
        NSMutableDictionary *distiller = [distillersSection objectAtIndex:row];
        cell.textLabel.text = [distiller objectForKey:@"name"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

/*
        if (section == WITH_INVENTORY) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }  
 */
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSUInteger section = [indexPath section];
/*
    if (section != WITH_INVENTORY) {
        return;
    }
*/
    
    NSUInteger row = [indexPath row];
    
    NSArray *distillerSection = [self.distillers objectForKey:[NSNumber numberWithInt:section]];
    NSDictionary *distiller = [distillerSection objectAtIndex:row]; 
    
    DistillerDetailViewController *controller = [[DistillerDetailViewController alloc] initWithNibName:@"DistillerDetailView" bundle:nil];
    controller.distillerId = [((NSString *)[distiller objectForKey:kId]) intValue];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
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
    
    [distillers setObject:selling forKey:[NSNumber numberWithInt:WITH_INVENTORY]];
    [distillers setObject:website_only forKey:[NSNumber numberWithInt:WEBSITE_ONLY]];
    
    // Loop over objects
    for (NSMutableDictionary *d in objects) {
        BOOL in_store = [((NSString *)[d objectForKey:@"in_store"]) boolValue];
        
        if (in_store == YES) {
            NSMutableArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:WITH_INVENTORY]];
            [list addObject:d];
        } else {
            NSMutableArray *list = [self.distillers objectForKey:[NSNumber numberWithInt:WEBSITE_ONLY]];
            [list addObject:d];
        }
    }
    
    [selling release];
    [website_only release];
    
    [super jsonParsingComplete:objects];
    
    [table reloadData];
}

@end
