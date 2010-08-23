//
//  RootViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController <UITabBarDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;

	NSArray *viewControllers;
	IBOutlet UITabBar *tabBar;
	IBOutlet UITabBarItem *categoriesTabBarItem;
	IBOutlet UITabBarItem *storesTabBarItem;
	IBOutlet UITabBarItem *spiritsTabBarItem;
	IBOutlet UITabBarItem *localDistillersTabBarItem;
	IBOutlet UITabBarItem *campaignTabBarItem;
	UIViewController *selectedViewController;
}

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) IBOutlet UITabBarItem *categoriesTabBarItem;
@property (nonatomic, retain) IBOutlet UITabBarItem *storesTabBarItem;
@property (nonatomic, retain) IBOutlet UITabBarItem *spiritsTabBarItem;
@property (nonatomic, retain) IBOutlet UITabBarItem *localDistillersTabBarItem;
@property (nonatomic, retain) IBOutlet UITabBarItem *campaignTabBarItem;
@property (nonatomic, retain) UIViewController *selectedViewController;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;

@end
