//
//  SpiritDetailViewController.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONLoaderController.h"
#import "AsyncImageView.h"
#import "HTTPUtil.h"

@interface SpiritDetailViewController : JSONLoaderController {
    NSString *spiritId;
    NSString *imageSrcUrl;
	HTTPUtil* http;
    
    IBOutlet UILabel *spiritName;
    IBOutlet UILabel *onSale;
    IBOutlet UIButton *priceBtn;
    IBOutlet UIButton *sizeBtn;
    IBOutlet UIButton *viewStoresBtn;
    IBOutlet AsyncImageView *image;
    IBOutlet UIButton *imageSrcBtn;
    
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic, retain) NSString *spiritId;
@property (nonatomic, retain) NSString *imageSrcUrl;

@property (nonatomic, retain) UILabel *spiritName;
@property (nonatomic, retain) UILabel *onSale;
@property (nonatomic, retain) UIButton *priceBtn;
@property (nonatomic, retain) UIButton *sizeBtn;
@property (nonatomic, retain) UIButton *viewStoresBtn;
@property (nonatomic, retain) AsyncImageView *image;
@property (nonatomic, retain) UIButton *imageSrcBtn;

@property (nonatomic, retain) UIScrollView *scrollView;

- (IBAction)viewStores:(id)sender;
- (IBAction)viewImageSrc:(id)sender;
@end
