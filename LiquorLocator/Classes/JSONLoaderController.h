//
//  JSONLoaderController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/31/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface JSONLoaderController : UIViewController <MBProgressHUDDelegate> {
    NSString *feedURLString;
    
    NSURLConnection *JSONConnection;
    NSURLResponse *response;
    NSMutableData *jsonData;
    
    id objectList;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) NSString *feedURLString;
@property (nonatomic, retain) NSURLConnection *JSONConnection;
@property (nonatomic, retain) NSMutableData *jsonData;
@property (nonatomic, retain) id objectList;

- (void)handleError:(NSError *)error;
- (void)jsonParsingComplete:(id)objects;

@end
