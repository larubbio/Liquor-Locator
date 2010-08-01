//
//  JSONLoaderController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/31/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "JSONLoaderController.h"
#import "JSON.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@implementation JSONLoaderController

@synthesize feedURLString;
@synthesize JSONConnection;
@synthesize jsonData;
@synthesize objectList;

@synthesize table;

- (void)viewDidAppear:(BOOL)animated {
    // Todo: Add cache.  Calling this twice and then scrolling before the list is reloaded causes a crash
    // since it attempts to get a cell yet I empty out the object list.
    self.objectList = [NSMutableArray array];
    
    NSLog([NSString stringWithFormat:@"Connecting to %@", self.feedURLString]);

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
    [jsonData release];
    [JSONConnection release];
    [response release];	
    [feedURLString release];
    [objectList release];

    [super dealloc];
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

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
    NSLog(@"Connection::didReceiveResponse");
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
    NSLog(@"Connection::didReceiveData");
    [jsonData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection::didFailWithError");
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
    NSLog(@"Connection::didFinishLoading");
    self.JSONConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
	// grab the JSON data as a string
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSAssert(jsonString != nil, @"TODO larubbio: handle no data!");
//    NSLog(jsonString);
    
    // Create new SBJSON parser object
    SBJSON *parser = [[SBJSON alloc] init];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON category objects
    self.objectList = [parser objectWithString:jsonString error:nil];
    
    // categoryData will be retained by the thread until parsecategoryData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.jsonData = nil;
    
    [table reloadData];
    
    [parser release];
    [jsonString release];
}

@end
