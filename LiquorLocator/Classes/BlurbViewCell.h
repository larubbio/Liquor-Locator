//
//  BlurbViewCell.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 8/1/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurbViewCell : UITableViewCell {
    IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;

@end
