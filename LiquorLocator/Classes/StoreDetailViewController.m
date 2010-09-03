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
#import "StoreCategoriesViewController.h"
#import "StoreAnnotation.h"

#import "Constants.h"
#import "FlurryAPI.h"

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
    double latitude = [((NSString *)[self.objectList objectForKey:kLat]) doubleValue];
    double longitude = [((NSString *)[self.objectList objectForKey:kLong]) doubleValue];
    
    NSString* startLocationParameter = [NSString stringWithFormat:@"%f,%f", userCoordinate.latitude, userCoordinate.longitude];    
    NSString* destinationLocationParameter= [NSString stringWithFormat:@"%f,%f", latitude, longitude];    
    NSString *googleURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%@", destinationLocationParameter, startLocationParameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]; 
	
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleURL]];
}

- (IBAction)callStoreManager:(id)sender {
    NSString *phone = nil;

    for (NSDictionary *contact in [self.objectList objectForKey:kContacts]) {
        NSString *role = [contact objectForKey:kRole];
        NSString *number = [contact objectForKey:kNumber];
        
        if ([role isEqualToString:kStoreManager]) {
            phone = number;
        }
    }

    [self call:phone];
}

- (IBAction)callDistrictManager:(id)sender {
    NSString *phone = nil;
    
    for (NSDictionary *contact in [self.objectList objectForKey:kContacts]) {
        NSString *role = [contact objectForKey:kRole];
        NSString *number = [contact objectForKey:kNumber];
        
        if ([role isEqualToString:kDistrictManager]) {
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
    
    StoreCategoriesViewController *controller = [[StoreCategoriesViewController alloc] initWithNibName:@"StoreCategoriesView" bundle:nil];
    ((StoreCategoriesViewController *)controller).storeId = storeId;
    ((StoreCategoriesViewController *)controller).storeName = storeName.text;

    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];

    [controller release];
}

    
#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
#ifdef FLURRY
    NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:[self.objectList objectForKey:kName], @"Store", nil]; 
    [FlurryAPI logEvent:@"StoreDetail" withParameters:searchParameters];
#endif
    
    // Pull all data out of the dictionary into local variables
    NSString *_name = [self.objectList objectForKey:kName];
    NSString *_street = [self.objectList objectForKey:kAddress];
//    NSString *_address2 = [self.objectList objectForKey:kAddress2];
    NSString *_city = [self.objectList objectForKey:kCity];
    NSString *_zip = [self.objectList objectForKey:kZip];
    double _latitude = [((NSString *)[self.objectList objectForKey:kLat]) doubleValue];
    double _longitude = [((NSString *)[self.objectList objectForKey:kLong]) doubleValue];
    
    for (NSDictionary *contact in [self.objectList objectForKey:kContacts]) {
        NSString *role = [contact objectForKey:kRole];
        NSString *name = [contact objectForKey:kName];
        NSString *number = [contact objectForKey:kNumber];
        
        if ([role isEqualToString:kStoreManager]) {
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
    for (NSDictionary *hours in [self.objectList objectForKey:kHours]) {
        NSString *startDay = [hours objectForKey:kStartDay];
        NSString *endDay = [hours objectForKey:kEndDay];
        NSString *open = [hours objectForKey:kOpen];
        NSString *close = [hours objectForKey:kClose];
        
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
