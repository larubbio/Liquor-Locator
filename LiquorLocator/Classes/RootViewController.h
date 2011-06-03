//
//  RootViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate, ADBannerViewDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;

	IBOutlet UIButton *categoriesButton;
	IBOutlet UIButton *storesButton;
	IBOutlet UIButton *spiritsButton;
	IBOutlet UIButton *localDistillersButton;
    IBOutlet UIButton *settingsButton;
    
    id _adBannerView;
    BOOL _adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet UIButton *categoriesButton;
@property (nonatomic, retain) IBOutlet UIButton *storesButton;
@property (nonatomic, retain) IBOutlet UIButton *spiritsButton;
@property (nonatomic, retain) IBOutlet UIButton *localDistillersButton;
@property (nonatomic, retain) IBOutlet UIButton *settingsButton;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;

@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

- (IBAction)viewCategories:(id)sender;
- (IBAction)viewSearch:(id)sender;
- (IBAction)viewStores:(id)sender;
- (IBAction)viewLocal:(id)sender;
- (IBAction)viewSettings:(id)sender;

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)createAdBannerView;
@end
