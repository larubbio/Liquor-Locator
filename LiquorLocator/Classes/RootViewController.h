//
//  RootViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;

	NSArray *viewControllers;
	IBOutlet UIButton *categoriesButton;
	IBOutlet UIButton *storesButton;
	IBOutlet UIButton *spiritsButton;
	IBOutlet UIButton *localDistillersButton;
    
    UIButton *selectedButton;
	UIViewController *selectedViewController;
}

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) IBOutlet UIButton *categoriesButton;
@property (nonatomic, retain) IBOutlet UIButton *storesButton;
@property (nonatomic, retain) IBOutlet UIButton *spiritsButton;
@property (nonatomic, retain) IBOutlet UIButton *localDistillersButton;
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) UIViewController *selectedViewController;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;

- (IBAction)viewCategories:(id)sender;
- (IBAction)viewSearch:(id)sender;
- (IBAction)viewStores:(id)sender;
- (IBAction)viewLocal:(id)sender;

@end
