//
//  CategoriesViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/29/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Category.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@implementation CategoriesViewController

@synthesize categoryList;
@synthesize categoryJSONConnection;
@synthesize categoryData;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidAppear:(BOOL)animated {
	// Initialize the array of earthquakes and pass a reference to that list to the Root view controller.
    self.categoryList = [NSMutableArray array];

    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://wsll.pugdogdev.com/categories";
    NSURLRequest *categoryURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.categoryJSONConnection = [[[NSURLConnection alloc] initWithRequest:categoryURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.categoryJSONConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [categoryData release];
    [categoryJSONConnection release];
    [response release];	
    [categoryList release];
    [super dealloc];
}

#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
	if (response != nil)
	{
		// according to the URL Loading System guide, it is possible to receive 
		// multiple responses in some cases (server redirects; multi-part MIME responses; etc)
		[response release];
	}
	response = [theResponse retain];
    self.categoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [categoryData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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
    self.categoryJSONConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.categoryJSONConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    // Spawn a thread to fetch the earthquake data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
//    [NSThread detachNewThreadSelector:@selector(parseEarthquakeData:) toTarget:self withObject:earthquakeData];
	// determine the proper encoding based on the HTTP response, if available
	// (otherwise, assume UTF-8 encoding.)
	NSString *textEncodingName = [response textEncodingName];
	NSStringEncoding likelyEncoding = NSUTF8StringEncoding;
	if (textEncodingName != nil)
	{
		CFStringRef cfsr_textEncodingName = (CFStringRef) textEncodingName;
		CFStringEncoding cf_encoding = CFStringConvertIANACharSetNameToEncoding(cfsr_textEncodingName);
		likelyEncoding = CFStringConvertEncodingToNSStringEncoding(cf_encoding);
	}
	
	// grab the JSON data as a string
	NSString *jsonString = [[NSString alloc] initWithData:categoryData encoding:likelyEncoding];
    NSLog(jsonString);
    
    // earthquakeData will be retained by the thread until parseEarthquakeData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.categoryData = nil;
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}
@end
