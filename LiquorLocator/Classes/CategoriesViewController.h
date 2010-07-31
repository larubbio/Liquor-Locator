//
//  CategoriesViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoriesViewController : UIViewController 
    <UITableViewDelegate, UITableViewDataSource> {
	NSArray *categoryList;
    
    // for downloading the xml data
    NSURLConnection *categoryJSONConnection;
    NSURLResponse *response;
    NSMutableData *categoryData;
        
    IBOutlet UITableView *table;
}

@property (nonatomic, retain) NSArray *categoryList;
@property (nonatomic, retain) NSURLConnection *categoryJSONConnection;
@property (nonatomic, retain) NSMutableData *categoryData;

@property (nonatomic, retain) UITableView *table;

- (void)handleError:(NSError *)error;
@end
