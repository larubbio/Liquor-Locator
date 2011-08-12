//
//  StoreListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/3/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "StoreListViewController.h"
#import "FlurryAPI.h"

@implementation StoreListViewController

@synthesize spiritId;
@synthesize spiritName;

- (void)viewDidAppear:(BOOL)animated {
#ifdef FLURRY
    NSDictionary *params= [NSDictionary dictionaryWithObjectsAndKeys:spiritName, @"Spirit", nil]; 
    [FlurryAPI logEvent:@"StoresView" withParameters:params];
#endif
    
    NSString *query = [NSString stringWithFormat:@"http://wsll.pugdogdev.com/spirit/%@/stores", spiritId];
    self.feedURLString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAdBannerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fixupAdView:[UIDevice currentDevice].orientation];
}

- (void)dealloc {
    [spiritId release];
    [super dealloc];
}

@end
