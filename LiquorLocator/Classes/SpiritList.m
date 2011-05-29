//
//  SpiritList.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/7/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritList.h"
#import "SpiritListViewController.h"
#import "SpiritDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

#import "Constants.h"

@implementation SpiritList

@synthesize table;

@synthesize spirits;
@synthesize keys;

@synthesize indexed;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAdBannerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fixupAdView:[UIDevice currentDevice].orientation];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [table release];
    [spirits release];
    [keys release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark JSON
- (void)jsonParsingComplete:(id)objects {
    if (spirits != nil) {
        [spirits release];
        spirits = nil;
    }
    spirits = [[NSMutableDictionary alloc] init];
    
    if (keys != nil) {
        [keys release];
        keys = nil;
    }
    
    // Loop over objects
    for (NSMutableDictionary *spirit in objects) {
        NSString *firstLetter = [[spirit objectForKey:kShortName] substringToIndex:1];

        if ([self.spirits objectForKey:firstLetter]) {
            NSMutableArray *list = [self.spirits objectForKey:firstLetter];
            [list addObject:spirit];
        } else {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject:spirit];
            [self.spirits setObject:list forKey:firstLetter];
            
            [list release];
        }
    }
    
    NSArray *array = [[spirits allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.keys = array;
    
    [super jsonParsingComplete:objects];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [keys objectAtIndex:section];
    NSArray *spiritSection = [spirits objectForKey:key];

    return [spiritSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SingleSpiritCellIdentifier = @"SingleSpiritCellIdentifier";
    static NSString *MultiSpiritCellIdentifier = @"MultiSpiritCellIdentifier";
    
    UITableViewCell *cell;
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *spiritSection = [spirits objectForKey:key];
    NSDictionary *spirit = [spiritSection objectAtIndex:row]; 

    if ([spirit objectForKey:kId]) {
        cell = [tableView dequeueReusableCellWithIdentifier:SingleSpiritCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SingleSpiritCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        NSString *detail = [NSString stringWithFormat:@"Size: %@ Price: $%@", [spirit objectForKey:kShortSize], [spirit objectForKey:kShortPrice]];
        cell.detailTextLabel.text = detail;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:MultiSpiritCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MultiSpiritCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.detailTextLabel.text = [spirit objectForKey:kShortCount];
    }

    cell.textLabel.text = [spirit objectForKey:kShortName];
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (indexed && [keys count] > 10) {
        return keys;
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id controller;

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *spiritSection = [spirits objectForKey:key];
    NSDictionary *spirit = [spiritSection objectAtIndex:row]; 
    
    if ([spirit objectForKey:kId]) {
        controller = [[SpiritDetailViewController alloc] initWithNibName:@"SpiritDetailView" bundle:nil];
        ((SpiritDetailViewController *)controller).spiritId = [spirit objectForKey:kId];
    } else {
        controller = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];   
        ((SpiritListViewController *)controller).brandName = [spirit objectForKey:kShortName];
    }
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

@end
