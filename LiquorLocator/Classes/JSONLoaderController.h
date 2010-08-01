//
//  JSONLoaderController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/31/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JSONLoaderController : UIViewController {
    NSString *feedURLString;
    
    NSURLConnection *JSONConnection;
    NSURLResponse *response;
    NSMutableData *jsonData;
    
    NSMutableArray *objectList;
    
    IBOutlet UITableView *table;    
}

@property (nonatomic, retain) NSString *feedURLString;
@property (nonatomic, retain) NSURLConnection *JSONConnection;
@property (nonatomic, retain) NSMutableData *jsonData;
@property (nonatomic, retain) NSMutableArray *objectList;

@property (nonatomic, retain) UITableView *table;

- (void)handleError:(NSError *)error;

@end
