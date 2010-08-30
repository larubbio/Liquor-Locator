//
//  DistillerDetailViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/23/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "DistillerDetailViewController.h"
#import "SpiritDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"

#import "DistillerAddressCell.h"
#import "StoreAnnotation.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation DistillerDetailViewController

@synthesize distillerId;
@synthesize table;
@synthesize addressCell;

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/distiller/%d", distillerId];
    
    [super viewDidAppear:animated];
}


- (void)dealloc {
    [table release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 1;
    } else {
        NSArray *list = [self.objectList objectForKey:kSpirits];

        if ([list count] > 0) {
          return [list count];
        } else {
          return 1;
        }
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *ret;

    if (section == 0) {
        if (self.objectList != nil) {
            ret = [self.objectList objectForKey:kName];
        } else {
            ret = nil;
        }
    } else if (section == 1) {
        ret = @"URL";
    } else if (section == 2) {
        ret = @"Spirits";
    }
    
    return ret;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSUInteger section = [indexPath section];
    if (section == 0) {
        return 105;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *DistillerCellIdentifier = @"DistillerCellIdentifier"; 
     static NSString *URLCellIdentifier = @"URLCellIdentifier";
     static NSString *SingleSpiritCellIdentifier = @"SingleSpiritCellIdentifier";

     NSUInteger section = [indexPath section];
     NSUInteger row = [indexPath row];

     UITableViewCell *cell;

    // For section 0 I need the custom cell with map and address
     if (section == 0) {
        DistillerAddressCell *dac = (DistillerAddressCell *)[tableView dequeueReusableCellWithIdentifier:DistillerCellIdentifier];
        if ( dac == nil ) {
            [[NSBundle mainBundle] loadNibNamed:@"DistillerAddressCell" owner:self options:nil];
            dac = self.addressCell;
        }

        dac.street.text = [self.objectList objectForKey:kStreet];
        dac.address.text = [self.objectList objectForKey:kAddress];
        //        dac.phone.text = ;

        double _latitude = [((NSString *)[self.objectList objectForKey:kLat]) doubleValue];
        double _longitude = [((NSString *)[self.objectList objectForKey:kLong]) doubleValue];

        StoreAnnotation *store = [[StoreAnnotation alloc] init];
        store.latitude = _latitude;
        store.longitude = _longitude;
    
        MKCoordinateRegion region;
        region.center = store.coordinate;
        MKCoordinateSpan span = {0.005, 0.005};
        region.span = span;
        dac.map.region = region;
    
        [dac.map addAnnotation:store];
         
        cell = dac;
         
        [store release];
    }

    // For section 1 a simple cell with text
    if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:URLCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:URLCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        cell.textLabel.text = [self.objectList objectForKey:kURL];
    }
    
    // For section 2 I need the spirit cell
    if (section == 2) {
        NSArray *spiritSection = [self.objectList objectForKey:kSpirits];
        NSDictionary *spirit = nil;
        
        cell = [tableView dequeueReusableCellWithIdentifier:SingleSpiritCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SingleSpiritCellIdentifier] autorelease];
        }
        
        if ([spiritSection count] > 0) {
            spirit = [spiritSection objectAtIndex:row]; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [spirit objectForKey:kBrandName];
            
            NSString *detail = [NSString stringWithFormat:@"Size: %@ Price: $%@", [spirit objectForKey:kSize], [spirit objectForKey:kPrice]];
            cell.detailTextLabel.text = detail;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"Coming Soon";
        }            
    }

    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    NSArray *spiritSection = [self.objectList objectForKey:kSpirits];
    NSDictionary *spirit = [spiritSection objectAtIndex:row]; 

    // For section 0 load map?  Call number?
    
    // For section 1 open url in safari
    
    // For section 2 go to spirit detail page.
    if (section == 2) {
        SpiritDetailViewController *controller = [[SpiritDetailViewController alloc] initWithNibName:@"SpiritDetailView" bundle:nil];
        ((SpiritDetailViewController *)controller).spiritId = [spirit objectForKey:kId];
    
        LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:controller animated:YES];
    
        [controller release];
    }
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
    
    NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:[self.objectList objectForKey:kName], @"Distiller", nil]; 
    [FlurryAPI logEvent:@"DistillerDetail" withParameters:searchParameters];
}

@end
