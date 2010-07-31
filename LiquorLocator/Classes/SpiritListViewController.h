//
//  SpiritListViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpiritListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSString *category;
    
    // Store
	NSArray *spiritList;
    
    // for downloading the xml data
    NSURLConnection *spiritJSONConnection;
    NSURLResponse *response;
    NSMutableData *spiritData;
    
    IBOutlet UITableView *table;
}

@property (nonatomic, retain) NSString *category;

@property (nonatomic, retain) NSArray *spiritList;
@property (nonatomic, retain) NSURLConnection *spiritJSONConnection;
@property (nonatomic, retain) NSMutableData *spiritData;

@property (nonatomic, retain) UITableView *table;

- (void)handleError:(NSError *)error;
- (void)setCategory:(NSString *)category;

@end
