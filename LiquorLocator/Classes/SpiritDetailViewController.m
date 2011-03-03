//
//  SpiritDetailViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritDetailViewController.h"
#import "StoreListViewController.h"
#import "LiquorLocatorAppDelegate.h"

#import "Constants.h"
#import "FlurryAPI.h"
#import "SBJSON.h"

#import "NSString+URLEncoding.h"

@implementation SpiritDetailViewController

@synthesize spiritId;
@synthesize image;
@synthesize imageSrcBtn;
@synthesize imageSrcUrl;

@synthesize spiritName;
@synthesize onSale;
@synthesize priceBtn;
@synthesize sizeBtn;
@synthesize viewStoresBtn;

- (void)viewDidLoad {
    http = [[HTTPUtil alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    self.feedURLString = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirit/%@", spiritId];
    
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [spiritId release];
    [spiritName release];
    [onSale release];
    [priceBtn release];
    [sizeBtn release];
    [viewStoresBtn release];
    [http release];
    [image release];
    [imageSrcBtn release];
    [imageSrcUrl release];
    [super dealloc];
}

- (void)viewStores:(id)sender {
    StoreListViewController *controller = [[StoreListViewController alloc] initWithNibName:@"StoreListView" bundle:nil];   
    ((StoreListViewController *)controller).spiritId = spiritId;
    ((StoreListViewController *)controller).spiritName = [self.objectList objectForKey:kBrandName];
    
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:controller animated:YES];
    
    [controller release];
}

- (void) viewImageSrc:(id)sender {
    if (imageSrcUrl != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:imageSrcUrl]];
    }
}

#pragma mark -
#pragma mark JSON Parsing Method
- (void)jsonParsingComplete:(id)objects {
    [super jsonParsingComplete:objects];
    
#ifdef FLURRY
    NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:[self.objectList objectForKey:kBrandName], @"Spirit", nil]; 
    [FlurryAPI logEvent:@"SpiritDetail" withParameters:searchParameters];
#endif
    
    if ([self.image loadedImage] == nil) {
        NSString *urlString = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&key=%@", 
                                        [[objectList objectForKey:kBrandName] urlEncodeUsingEncoding:NSUTF8StringEncoding],
                                        @"ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA"];
    
        [http sendAsyncGetRequestWithURL:[NSURL URLWithString:urlString] 
                              parameters:nil 
                        additionalHeaderFields:nil
                         timeoutInterval:15
                                      to:self 
                                selector:@selector(googleImageSearchComplete:)];
    }
    
    NSString *priceTitle = [NSString stringWithFormat:@"Cost: $%@", [objectList objectForKey:kPrice]];
    NSString *sizeTitle = [NSString stringWithFormat:@"Size: %@ Liters", [objectList objectForKey:kSize]];
    
    spiritName.text = [objectList objectForKey:kBrandName];
    spiritName.hidden = NO;
    
    BOOL on_sale = [((NSString *)[objectList objectForKey:kOnSale]) boolValue];
    BOOL closeout = [((NSString *)[objectList objectForKey:kCloseout]) boolValue];
    
    if (on_sale && closeout) {
        onSale.text = @"This product is on sale and closeout.";
        onSale.hidden = NO;
    } else if (on_sale) {
        onSale.text = @"This product is on sale.";
        onSale.hidden = NO;
    } else if (closeout) {
        onSale.text = @"This product is on closeout.";
        onSale.hidden = NO;
    }    
    [priceBtn setTitle:priceTitle forState:UIControlStateNormal];
    priceBtn.hidden = NO;
    [sizeBtn setTitle:sizeTitle forState:UIControlStateNormal];
    sizeBtn.hidden = NO;
    
    viewStoresBtn.hidden = NO;
    
    self.title = [objectList objectForKey:kBrandName];
}

- (void)googleImageSearchComplete:(NSDictionary*)theResponse
{
	int statusCode = [[theResponse objectForKey:kHTTP_ASYNC_RESULT_CODE] intValue];
	if(statusCode == 200)
	{
        NSString *jsonString = [[NSString alloc] initWithData:(NSData*)[theResponse objectForKey:kHTTP_ASYNC_RESULT_DATA] 
                                                 encoding:NSUTF8StringEncoding];
        
        SBJSON *parser = [[SBJSON alloc] init];
        
        // parse the JSON response into an object
        NSError *error;
        NSDictionary *objects = (NSDictionary *)[parser objectWithString:jsonString error:&error];
        NSDictionary *responseData = [objects objectForKey:@"responseData"];
        
        if (responseData) {
            NSArray *results = [responseData objectForKey:@"results"];
            
            if ([results count] > 0) {
                NSDictionary *firstResult = [results objectAtIndex:0];
                NSString *url = [firstResult objectForKey:@"url"];
        
                [image loadImageWithURLString:url parameters:nil 
                       additionalHeaderFields:nil timeoutInterval:15];
                
                NSString *imgSrcTitle = [NSString stringWithFormat:@"image: %@", [firstResult objectForKey:@"visibleUrl"]];
                
                [imageSrcBtn setTitle:imgSrcTitle forState:UIControlStateNormal];
                imageSrcBtn.hidden = NO;        
                
                self.imageSrcUrl = [firstResult objectForKey:@"originalContextUrl"];
            }
        }

        [parser release];
        [jsonString release];
	}
}

@end
