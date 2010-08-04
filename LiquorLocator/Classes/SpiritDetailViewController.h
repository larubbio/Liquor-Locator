//
//  SpiritDetailViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"

@interface SpiritDetailViewController : JSONLoaderController {
    NSString *spiritId;
    
    IBOutlet UIButton *priceBtn;
    IBOutlet UIButton *sizeBtn;
    IBOutlet UIButton *viewStoresBtn;
}

@property (nonatomic, retain) NSString *spiritId;

@property (nonatomic, retain) UIButton *priceBtn;
@property (nonatomic, retain) UIButton *sizeBtn;
@property (nonatomic, retain) UIButton *viewStoresBtn;

- (IBAction)viewStores:(id)sender;
@end
