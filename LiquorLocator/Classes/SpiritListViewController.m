//
//  SpiritListViewController.m
//  LiquorLocator
//
//  Created by Rob LaRubbio on 7/30/10.
//  Copyright 2010 Pug Dog Dev LLC. All rights reserved.
//

#import "SpiritListViewController.h"

#import "JSON.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@implementation SpiritListViewController

@synthesize category;

@synthesize spiritList;
@synthesize spiritJSONConnection;
@synthesize spiritData;

@synthesize table;


- (void)viewDidAppear:(BOOL)animated {
	// Initialize the array of earthquakes and pass a reference to that list to the Root view controller.
    self.spiritList = [NSMutableArray array];
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://wsll.pugdogdev.com/spirits?";
    NSString *query = [NSString stringWithFormat:@"category=%@", category];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *spiritsFeedURLString = [feedURLString stringByAppendingString:query];
    
    NSURLRequest *spiritURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:spiritsFeedURLString]];
    self.spiritJSONConnection = [[[NSURLConnection alloc] initWithRequest:spiritURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.spiritJSONConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [category release];
    [spiritData release];
    [spiritJSONConnection release];
    [response release];	
    [spiritList release];    
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.spiritList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SpiritTableIdentifier = @"SpiritTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SpiritTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SpiritTableIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary *spirit = [spiritList objectAtIndex:row]; 
    cell.text = [spirit objectForKey:@"brand_name"];
    
    return cell;
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
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
    self.spiritData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [spiritData appendData:data];
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
    self.spiritJSONConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.spiritJSONConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
	// grab the JSON data as a string
	NSString *jsonString = [[NSString alloc] initWithData:spiritData encoding:NSUTF8StringEncoding];
	NSAssert(jsonString != nil, @"TODO larubbio: handle no data!");
    NSLog(jsonString);
    
    // Create new SBJSON parser object
    SBJSON *parser = [[SBJSON alloc] init];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON category objects
    self.spiritList = [parser objectWithString:jsonString error:nil];
    
    // categoryData will be retained by the thread until parsecategoryData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.spiritData = nil;
    
    [table reloadData];
    
    [parser release];
    [jsonString release];
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

