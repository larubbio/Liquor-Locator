//
//  CategoriesViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoriesViewController : UIViewController {
	NSMutableArray *categoryList;
    
    // for downloading the xml data
    NSURLConnection *categoryJSONConnection;
    NSURLResponse *response;
    NSMutableData *categoryData;    
}

@property (nonatomic, retain) NSMutableArray *categoryList;
@property (nonatomic, retain) NSURLConnection *categoryJSONConnection;
@property (nonatomic, retain) NSMutableData *categoryData;

- (void)handleError:(NSError *)error;
@end
