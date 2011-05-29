//
//  StoreDetailViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/2/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JSONLoaderController.h"


@interface StoreDetailViewController : JSONLoaderController {
    int storeId;
    
    IBOutlet UILabel *storeName;
    IBOutlet UILabel *street;
    IBOutlet UILabel *address2;
    IBOutlet UILabel *cityZip;
    IBOutlet UILabel *storeManagerName;
    IBOutlet UILabel *storeManagerPhone;
    IBOutlet UILabel *districtManagerName;
    IBOutlet UILabel *districtManagerPhone;

    IBOutlet UILabel *monHours;
    IBOutlet UILabel *tueHours;
    IBOutlet UILabel *wedHours;
    IBOutlet UILabel *thursHours;
    IBOutlet UILabel *friHours;
    IBOutlet UILabel *satHours;
    IBOutlet UILabel *sunHours;

    IBOutlet UILabel *mon;
    IBOutlet UILabel *tue;
    IBOutlet UILabel *wed;
    IBOutlet UILabel *thurs;
    IBOutlet UILabel *fri;
    IBOutlet UILabel *sat;
    IBOutlet UILabel *sun;

    IBOutlet UILabel *openClosed;
    
    IBOutlet UIView *mask;
    IBOutlet UIView *districtManagerView;
    IBOutlet MKMapView *map;
    
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic, assign) int storeId;

@property (nonatomic, retain) UILabel *storeName;
@property (nonatomic, retain) UILabel *street;
@property (nonatomic, retain) UILabel *address2;
@property (nonatomic, retain) UILabel *cityZip;
@property (nonatomic, retain) UILabel *storeManagerName;
@property (nonatomic, retain) UILabel *storeManagerPhone;
@property (nonatomic, retain) UILabel *districtManagerName;
@property (nonatomic, retain) UILabel *districtManagerPhone;

@property (nonatomic, retain) UILabel *monHours;
@property (nonatomic, retain) UILabel *tueHours;
@property (nonatomic, retain) UILabel *wedHours;
@property (nonatomic, retain) UILabel *thursHours;
@property (nonatomic, retain) UILabel *friHours;
@property (nonatomic, retain) UILabel *satHours;
@property (nonatomic, retain) UILabel *sunHours;

@property (nonatomic, retain) UILabel *mon;
@property (nonatomic, retain) UILabel *tue;
@property (nonatomic, retain) UILabel *wed;
@property (nonatomic, retain) UILabel *thurs;
@property (nonatomic, retain) UILabel *fri;
@property (nonatomic, retain) UILabel *sat;
@property (nonatomic, retain) UILabel *sun;

@property (nonatomic, retain) UILabel *openClosed;

@property (nonatomic, retain) UIView *mask;
@property (nonatomic, retain) UIView *districtManagerView;
@property (nonatomic, retain) MKMapView *map;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)directions:(id)sender;
- (IBAction)callStoreManager:(id)sender;
- (IBAction)callDistrictManager:(id)sender;
- (IBAction)viewSpirits:(id)sender;

- (void)call:(NSString *)phone;

@end
