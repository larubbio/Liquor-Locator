//
//  NSString+URLEncoding.h
//  LiquorLocator
//
//  Created by Rob LaRubbio on 3/1/11.
//  Copyright 2011 Pug Dog Dev LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
