//
//  StoreDetailViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/2/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "LiquorLocatorAppDelegate.h"
#import "RootViewController.h"
#import "SpiritListViewController.h"
#import "StoreAnnotation.h"


@implementation StoreDetailViewController

@synthesize storeId;

@synthesize storeName;                                                                              
@synthesize street;                                                                            
@synthesize address2;                                                                          
@synthesize cityZip;                                                                           
@synthesize storeManagerName;                                                                  
@synthesize storeManagerPhone;                                                                 
@synthesize districtManagerName;                                                               
@synthesize districtManagerPhone; 

@synthesize firstHours;
@synthesize day1;
@synthesize hours1;

@synthesize secondHours;
@synthesize day2;
@synthesize hours2;

@synthesize thirdHours;
@synthesize day3;
@synthesize hours3;

@synthesize fourthHours;
@synthesize day4;
@synthesize hours4;

@synthesize mask;
@synthesize districtManagerView;
@synthesize map;

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d", storeId];
    
    [super viewDidAppear:animated];
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
    [storeName release];                                                                                
    [street release];                                                                              
    [address2 release];                                                                            
    [cityZip release];                                                                             
    [storeManagerName release];                                                                    
    [storeManagerPhone release];                                                                   
    [districtManagerName release];                                                                 
    [districtManagerPhone release];                                                                

    [map release];
    [super dealloc];
}

- (IBAction)directions:(id)sender {
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    RootViewController *rootView = [delegate.navController.viewControllers objectAtIndex:0];

	CLLocationCoordinate2D userCoordinate = rootView.userLocation.coordinate;
    double latitude = [((NSString *)[self.objectList objectForKey:@"lat"]) doubleValue];
    double longitude = [((NSString *)[self.objectList objectForKey:@"long"]) doubleValue];
    
	NSString* startLocationParameter = [NSString stringWithFormat:@"%f,%f", userCoordinate.latitude, userCoordinate.longitude];    
	NSString* destinationLocationParameter= [NSString stringWithFormat:@"%f,%f", latitude, longitude];    
	NSString *googleURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%@", destinationLocationParameter, startLocationParameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]; 
	
	NSLog(@"Directions URL: %@",googleURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleURL]];
}

- (IBAction)callStoreManager:(id)sender {
    NSString *phone = nil;

    for (NSDictionary *contact in [self.objectList objectForKey:@"contacts"]) {
        NSString *role = [contact objectForKey:@"role"];
        NSString *number = [contact objectForKey:@"number"];
        
        if ([role isEqualToString:@"Store Manager"]) {
            phone = number;
        }
    }

    [self call:phone];
}

- (IBAction)callDistrictManager:(id)sender {
    NSString *phone = nil;
    
    for (NSDictionary *contact in [self.objectList objectForKey:@"contacts"]) {
        NSString *role = [contact objectForKey:@"role"];
        NSString *number = [contact objectForKey:@"number"];
        
        if ([role isEqualToString:@"District Manager"]) {
            phone = number;
        }
    }
    
    [self call:phone];
}

- (void)call:(NSString *)phone {
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

- (IBAction)viewSpirits:(id)sender {
    SpiritListViewController *controller = [[SpiritListViewController alloc] initWithNibName:@"SpiritListView" bundle:nil];   
    ((SpiritListViewController *)controller).storeId = storeId;
    ((SpiritListViewController *)controller).storeName = storeName.text;

    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];

    [controller release];
}

    
#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
    // Pull all data out of the dictionary into local variables
    NSString *_name = [self.objectList objectForKey:@"name"];
    NSString *_street = [self.objectList objectForKey:@"address"];
//    NSString *_address2 = [self.objectList objectForKey:@"address2"];
    NSString *_city = [self.objectList objectForKey:@"city"];
    NSString *_zip = [self.objectList objectForKey:@"zip"];
    double _latitude = [((NSString *)[self.objectList objectForKey:@"lat"]) doubleValue];
    double _longitude = [((NSString *)[self.objectList objectForKey:@"long"]) doubleValue];
    
    for (NSDictionary *contact in [self.objectList objectForKey:@"contacts"]) {
        NSString *role = [contact objectForKey:@"role"];
        NSString *name = [contact objectForKey:@"name"];
        NSString *number = [contact objectForKey:@"number"];
        
        if ([role isEqualToString:@"Store Manager"]) {
            storeManagerName.text = name;
            storeManagerPhone.text = number;
        } else {
            districtManagerName.text = name;
            districtManagerPhone.text = number;
            districtManagerView.hidden = NO;
        }
    }
    
    // Handle hours
    int count = 0;
    for (NSDictionary *hours in [self.objectList objectForKey:@"hours"]) {
        NSString *startDay = [hours objectForKey:@"start_day"];
        NSString *endDay = [hours objectForKey:@"end_day"];
        NSString *open = [hours objectForKey:@"open"];
        NSString *close = [hours objectForKey:@"close"];
        
        // For now ignore summer hours
        NSNumber *summerHours = [hours objectForKey:@"summer_hours"];
        
        if ([summerHours boolValue]) continue;
        
        if (count == 0) {
            if ([startDay isEqualToString:endDay]) {
                day1.text = startDay;
            } else {
                day1.text = [NSString stringWithFormat:@"%@ - %@", startDay, endDay];
            }
            hours1.text = [NSString stringWithFormat:@"%@ - %@", open, close];
            firstHours.hidden = NO;
            
        } else if (count == 1) {
            if ([startDay isEqualToString:endDay]) {
                day2.text = startDay;
            } else {    
                day2.text = [NSString stringWithFormat:@"%@ - %@", startDay, endDay];
            }            
            hours2.text = [NSString stringWithFormat:@"%@ - %@", open, close];
            secondHours.hidden = NO;

        } else if (count == 2) {
            if ([startDay isEqualToString:endDay]) {
                day3.text = startDay;
            } else {
                day3.text = [NSString stringWithFormat:@"%@ - %@", startDay, endDay];
            }            
            hours3.text = [NSString stringWithFormat:@"%@ - %@", open, close];
            thirdHours.hidden = NO;

        } else if (count == 3) {
            if ([startDay isEqualToString:endDay]) {
                day4.text = startDay;
            } else {
                day4.text = [NSString stringWithFormat:@"%@ - %@", startDay, endDay];
            }            
            hours4.text = [NSString stringWithFormat:@"%@ - %@", open, close];
            fourthHours.hidden = NO;
        }
        
        count = count + 1;
    }
    
    // Add data to view outlets
    storeName.text = [NSString stringWithFormat:@"%@ - #%d", _name, storeId];
    self.title = storeName.text;
    
    street.text = _street;
//    address2.text = _address2;
    cityZip.text = [NSString stringWithFormat:@"%@, WA %@", _city, _zip];
    
    StoreAnnotation *store = [[StoreAnnotation alloc] init];
  //  store.name = _name;
  //  store.address = _street;
    store.latitude = _latitude;
    store.longitude = _longitude;
    
    MKCoordinateRegion region;
    region.center = store.coordinate;
    MKCoordinateSpan span = {0.005, 0.005};
    region.span = span;
    map.region = region;
    
    [map addAnnotation:store];
    
    // Remove blocking view
    mask.hidden = YES;
    
    [store release];
}

@end
