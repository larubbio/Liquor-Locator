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
#import "RootViewController.h"

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

    // For section 0 load map?  Call number?
    
    // For section 1 open url in safari
    if (section == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.objectList objectForKey:kURL]]];
    }
    
    // For section 2 go to spirit detail page.
    if (section == 2) {
        NSArray *spiritSection = [self.objectList objectForKey:kSpirits];
        if ([spiritSection count] > 0) {
            NSDictionary *spirit = [spiritSection objectAtIndex:row]; 
        
            SpiritDetailViewController *controller = [[SpiritDetailViewController alloc] initWithNibName:@"SpiritDetailView" bundle:nil];
            ((SpiritDetailViewController *)controller).spiritId = [spirit objectForKey:kId];
    
            LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [delegate.navController pushViewController:controller animated:YES];
    
            [controller release];
        }
    }

    [tableView reloadData];
}
#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    [table reloadData];
    
#ifdef FLURRY
    NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:[self.objectList objectForKey:kName], @"Distiller", nil]; 
    [FlurryAPI logEvent:@"DistillerDetail" withParameters:searchParameters];
#endif
}

#pragma mark -
#pragma mark IBAction methods
- (IBAction)loadDirections:(id)sender {
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];
    
    CLLocationCoordinate2D userCoordinate = rootView.userLocation.coordinate;
    double latitude = [((NSString *)[self.objectList objectForKey:kLat]) doubleValue];
    double longitude = [((NSString *)[self.objectList objectForKey:kLong]) doubleValue];
    
    NSString* startLocationParameter = [NSString stringWithFormat:@"%f,%f", userCoordinate.latitude, userCoordinate.longitude];    
    NSString* destinationLocationParameter= [NSString stringWithFormat:@"%f,%f", latitude, longitude];    
    NSString *googleURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%@", destinationLocationParameter, startLocationParameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]; 
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleURL]];
}

- (IBAction)callDistiller:(id)sender {
    NSString *phone = [self.objectList objectForKey:kNumber];
    if (phone) {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"-() ."];
        phone = [[phone componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
        NSString *phoneURL = [NSString stringWithFormat:@"tel://%@", phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"I'm soooo sorry." 
							  message:@"I wasn't able to find a phone for this store, so I can't call it for you"
							  delegate:nil 
							  cancelButtonTitle:@"Okay" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];        
    }
}


@end
