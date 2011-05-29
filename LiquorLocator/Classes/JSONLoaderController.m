//
//  JSONLoaderController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/31/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "JSONLoaderController.h"
#import "JSON.h"
#import <unistd.h>

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>
#import "LiquorLocatorAppDelegate.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation JSONLoaderController

@synthesize feedURLString;
@synthesize JSONConnection;
@synthesize jsonData;
@synthesize objectList;

@synthesize contentView = _contentView;
@synthesize adBannerView = _adBannerView;
@synthesize adBannerViewIsVisible = _adBannerViewIsVisible;

- (void)viewDidAppear:(BOOL)animated {
    HUD = nil;
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    // Check out cache
    id objects = [delegate getCachedDataForKey:self.feedURLString];
    if (objects != nil) {
        [self jsonParsingComplete:objects];
        return;
    }

    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Initialize the HUD with my view
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	
    // Add HUD to screen
    [self.view addSubview:HUD];
	
    // Regisete for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    HUD.labelText = kLoading;

    // Show the HUD while the we load and parse data
    [HUD show:YES];
    
    // Todo: Add cache.  Calling this twice and then scrolling before the list is reloaded causes a crash
    // since it attempts to get a cell yet I empty out the object list.
    self.objectList = [NSMutableArray array];
    
//    NSLog(@"Connecting to %@", self.feedURLString);

    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.JSONConnection = [[[NSURLConnection alloc] initWithRequest:URLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.JSONConnection != nil, @"Failure to create URL connection.");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate purgeCache];
}

- (void)dealloc {
    if (HUD != nil) {
        HUD.delegate = nil;
    }
    
    [jsonData release];
    [JSONConnection release];
    [response release];	
    [feedURLString release];
    [objectList release];

    self.contentView = nil;
    self.adBannerView = nil;
    
    [super dealloc];
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
#ifdef FLURRY
    [FlurryAPI logError:@"Error" message:feedURLString error:error];
#endif
    
    if (HUD == nil) {
        // Initialize the HUD with my view
        HUD = [[MBProgressHUD alloc] initWithView:self.view];

        // Add HUD to screen
        [self.view addSubview:HUD];
        
        // Regisete for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        
        // Show the HUD while the we load and parse data
        [HUD show:YES];
    }

    // The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Sorry.";
    HUD.detailsLabelText = @"We were unable to access the data. ;(";
    
    [HUD showWhileExecuting:@selector(delay) onTarget:self withObject:nil animated:YES];
}

- (void)delay {
    sleep(3);
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
//    NSLog(@"Connection::didReceiveResponse");
	if (response != nil)
	{
		// according to the URL Loading System guide, it is possible to receive 
		// multiple responses in some cases (server redirects; multi-part MIME responses; etc)
		[response release];
	}
	response = [theResponse retain];
    self.jsonData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"Connection::didReceiveData");
    [jsonData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    NSLog(@"Connection::didFailWithError");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.JSONConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.JSONConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   

	NSString *jsonString = [[NSString alloc] initWithData:self.jsonData encoding:NSUTF8StringEncoding];
    
    SBJSON *parser = [[SBJSON alloc] init];
    
    // parse the JSON response into an object
    @try {
        NSError *error;
        id objects = [parser objectWithString:jsonString error:&error];

        if (objects == nil) {
            [self handleError:error];
        } else {
            [self jsonParsingComplete:objects];
        }
    } @catch (NSException *exception) {
        self.objectList = nil;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[exception name], @"ExceptionName",  
                                                                            [exception reason], @"ExceptionReason", nil]; 
        NSError *error = [NSError errorWithDomain:@"LiquorLocator" code:1 userInfo:userInfo];
        [self handleError:error];
    }
    
    [parser release];
    [jsonString release];
    
    self.jsonData = nil;
}
    
// The secondary (parsing) thread calls jsonParsingComplete: on the main thread with all of the parsed objects. 
- (void)jsonParsingComplete:(id)objects {
    LiquorLocatorAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate putCachedData:objects forKey:self.feedURLString];
    
    self.objectList = objects;
    
    // Hide my loading HUD
    if (HUD != nil) {
        [HUD hide:YES];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD is hidden
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

#pragma mark -
#pragma IAd Delegate Methods
- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
                              initWithFrame:CGRectMake(0, self.view.frame.size.height, 0, 0)] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
                                                          ADBannerContentSizeIdentifierPortrait, 
                                                          ADBannerContentSizeIdentifierLandscape, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];            
        }
        [_adBannerView setDelegate:self];
        
        [self.view addSubview:_adBannerView];        
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_adBannerView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (_adBannerViewIsVisible) {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
            [_adBannerView setFrame:adBannerViewFrame];

            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
            _contentView.frame = contentViewFrame;
        } else {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = self.view.frame.size.height;
            [_adBannerView setFrame:adBannerViewFrame];
            
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            _contentView.frame = contentViewFrame;           
        }
        [UIView commitAnimations];
    }   
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_adBannerViewIsVisible) {                
        _adBannerViewIsVisible = YES;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_adBannerViewIsVisible)
    {        
        _adBannerViewIsVisible = NO;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

@end
