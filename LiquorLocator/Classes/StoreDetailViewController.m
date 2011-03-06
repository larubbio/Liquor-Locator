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

@synthesize monHours;
@synthesize tueHours;
@synthesize wedHours;
@synthesize thursHours;
@synthesize friHours;
@synthesize satHours;
@synthesize sunHours;

@synthesize mon;
@synthesize tue;
@synthesize wed;
@synthesize thurs;
@synthesize fri;
@synthesize sat;
@synthesize sun;

@synthesize openClosed;

@synthesize mask;
@synthesize districtManagerView;
@synthesize map;

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/store/%d?hoursByDay=1", storeId];
    
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

    [monHours release];
    [tueHours release];
    [wedHours release];
    [thursHours release];
    [friHours release];
    [satHours release];
    [sunHours release];
    
    [openClosed release];
    
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

- (void)processLablesForDay:(UILabel *)dayLabel dayHoursLabel:(UILabel *)dayHoursLabel 
                  storeOpen:(NSString *)open storeClose:(NSString *)close
                    weekday:(NSInteger)weekday today:(NSInteger)today curTime:(NSInteger) curTime {

    if ( [open isEqual: [NSNull null]] ) {
        dayHoursLabel.text = @"Closed";
    } else {
        dayHoursLabel.text = [NSString stringWithFormat:@"%@ - %@", open, close];
    }
    
    if (weekday == today) {    
        dayLabel.font = [UIFont boldSystemFontOfSize:12];
        dayHoursLabel.font = [UIFont boldSystemFontOfSize:12];
        
        openClosed.text = @"CLOSED";
        if (![open isEqual:[NSNull null]] && ![close isEqual:[NSNull null]]) {
            NSArray *openItems = [open componentsSeparatedByString:@":"];
            NSInteger openTime = ([[openItems objectAtIndex:0] integerValue] * 100) + [[openItems objectAtIndex:1] integerValue];
    
            NSArray *closeItems = [close componentsSeparatedByString:@":"];
            NSInteger closingTime = (([[closeItems objectAtIndex:0] integerValue] + 12) * 100) + [[closeItems objectAtIndex:1] integerValue];
    
            if (curTime > openTime && curTime < closingTime) {  
                openClosed.text = @"OPEN";
            }
        }
    }
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
            if (![name isEqualToString:@""]) {
                districtManagerName.text = name;
                districtManagerPhone.text = number;
                districtManagerView.hidden = NO;
            }
        }
    }
    
    // Get the current day (Sun == 1)
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSCalendarUnit unitFlags = NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    NSInteger curTime = ([comps hour] * 100) + [comps minute];    
    
    // Handle hours
    for (NSDictionary *hours in [self.objectList objectForKey:kHours]) {
        NSString *startDay = [hours objectForKey:kStartDay];
        NSString *open = [hours objectForKey:kOpen];
        NSString *close = [hours objectForKey:kClose];

        
        if ([startDay isEqualToString:@"Sun"]) {
            [self processLablesForDay:sun dayHoursLabel:sunHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:1 curTime:curTime]; 
        }
        
        if ([startDay isEqualToString:@"Mon"]) {
            [self processLablesForDay:mon dayHoursLabel:monHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:2 curTime:curTime]; 
        }
        
        if ([startDay isEqualToString:@"Tue"]) {
            [self processLablesForDay:tue dayHoursLabel:tueHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:3 curTime:curTime]; 
        }
        
        if ([startDay isEqualToString:@"Wed"]) {
            [self processLablesForDay:wed dayHoursLabel:wedHours
                            storeOpen:open storeClose:close
                              weekday:weekday today:4 curTime:curTime]; 
        }

        if ([startDay isEqualToString:@"Thu"]) {
            [self processLablesForDay:thurs dayHoursLabel:thursHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:5 curTime:curTime]; 
        }
        
        if ([startDay isEqualToString:@"Fri"]) {
            [self processLablesForDay:fri dayHoursLabel:friHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:6 curTime:curTime]; 
        }
        
        if ([startDay isEqualToString:@"Sat"]) {
            [self processLablesForDay:sat dayHoursLabel:satHours 
                            storeOpen:open storeClose:close
                              weekday:weekday today:7 curTime:curTime]; 
        }
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
