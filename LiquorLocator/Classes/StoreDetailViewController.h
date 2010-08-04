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

    IBOutlet UIView  *firstHours;
    IBOutlet UILabel *day1;
    IBOutlet UILabel *hours1;

    IBOutlet UIView  *secondHours;
    IBOutlet UILabel *day2;
    IBOutlet UILabel *hours2;

    IBOutlet UIView  *thirdHours;
    IBOutlet UILabel *day3;
    IBOutlet UILabel *hours3;

    IBOutlet UIView  *fourthHours;
    IBOutlet UILabel *day4;
    IBOutlet UILabel *hours4;
    
    IBOutlet UIView *mask;
    IBOutlet UIView *districtManagerView;
    IBOutlet MKMapView *map;
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

@property (nonatomic, retain) UIView  *firstHours;
@property (nonatomic, retain) UILabel *day1;
@property (nonatomic, retain) UILabel *hours1;

@property (nonatomic, retain) UIView  *secondHours;
@property (nonatomic, retain) UILabel *day2;
@property (nonatomic, retain) UILabel *hours2;

@property (nonatomic, retain) UIView  *thirdHours;
@property (nonatomic, retain) UILabel *day3;
@property (nonatomic, retain) UILabel *hours3;

@property (nonatomic, retain) UIView  *fourthHours;
@property (nonatomic, retain) UILabel *day4;
@property (nonatomic, retain) UILabel *hours4;

@property (nonatomic, retain) UIView *mask;
@property (nonatomic, retain) UIView *districtManagerView;
@property (nonatomic, retain) MKMapView *map;

- (IBAction)directions:(id)sender;
- (IBAction)callStoreManager:(id)sender;
- (IBAction)callDistrictManager:(id)sender;
- (IBAction)viewSpirits:(id)sender;

- (void)call:(NSString *)phone;

@end
