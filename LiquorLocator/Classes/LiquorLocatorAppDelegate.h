//
//  LiquorLocatorAppDelegate.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright Pug Dog Dev LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiquorLocatorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
  
    IBOutlet UINavigationController *navController;
    IBOutlet UIView *splashView;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UIView *splashView;
@end

