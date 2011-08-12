//
//  JSONLoaderController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/31/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"
#import "MBProgressHUD.h"

@interface JSONLoaderController : UIViewController <MBProgressHUDDelegate, ADBannerViewDelegate> {
    NSString *feedURLString;
    
    NSURLConnection *JSONConnection;
    NSURLResponse *response;
    NSMutableData *jsonData;
    
    id objectList;
    
    MBProgressHUD *HUD;
    
    UIView *_contentView;
    id _adBannerView;
    BOOL _adBannerViewIsVisible;
}

@property (nonatomic, retain) NSString *feedURLString;
@property (nonatomic, retain) NSURLConnection *JSONConnection;
@property (nonatomic, retain) NSMutableData *jsonData;
@property (nonatomic, retain) id objectList;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

- (void)handleError:(NSError *)error;
- (void)jsonParsingComplete:(id)objects;

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)createAdBannerView;

@end
