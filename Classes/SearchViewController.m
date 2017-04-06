//
//  SearchViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "ProxyReader.h"
#import "Prefs.h"
#import "Gene.h"
#import "constants.h"
#import "ProxyUtil.h"
#import "InterfaceUtil.h"
#import "UIDevice+Resolutions.h"

// class extension for private properties and methods
@interface SearchViewController ()

@property (nonatomic, retain) UISearchBar *search;
@property (nonatomic, retain) IBOutlet UIButton *prefsButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;

-(void)getEntrezGeneData;

@end

@implementation SearchViewController

@synthesize search;
@synthesize prefsButton;
@synthesize infoButton;
@synthesize activityView;
@synthesize rootViewController;
@synthesize uiWebView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// setup activity view
	// numbers determined from interface builder
	CGRect activityViewRect = CGRectMake(kSearchViewActivityViewX, kSearchViewActivityViewY, kActivityViewWidth, kActivityViewHeight);
	activityView = [[UIActivityIndicatorView alloc] initWithFrame:activityViewRect];
	activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	activityView.hidden = YES;
	
	// we only detect hyperlinks (no phone numbers)
	self.uiWebView.dataDetectorTypes = UIDataDetectorTypeLink;

	// load uiWebView from local html file
    NSString *htmlFile = ([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes) ? @"taller-home" : @"home";
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:htmlFile ofType:@"html" inDirectory:@"html"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
	[uiWebView loadRequest:request];
	
	// setup rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.activityView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
										  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);

	// insert uiWebView into our view stack
	[self.view insertSubview:uiWebView atIndex:0];
	
	// we want activity indicator at top
	[self.view insertSubview:activityView atIndex:1];
	
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    return ([InterfaceUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation prefs:self.rootViewController.prefs]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[self.search release];
	[self.prefsButton release];
	[self.infoButton release];
	[self.activityView release];
	[self.rootViewController release];
	[self.uiWebView release];
    [super dealloc];
}

-(IBAction)prefsView:(id)sender {
	[self.rootViewController prefsView];
}

-(IBAction)infoView:(id)sender {
	[self.rootViewController infoView];
}

#pragma mark UISearchBarDelegate delegate methods

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if ([search.text isEqualToString:@"chenjiexoxoxo"]) {
		NSString *miscString = [NSString stringWithFormat:@"This, my first iPhone application, I dedicate to my most beautiful Cherry and son Jagger..."];
 		miscString = [miscString stringByAppendingString:[NSString stringWithFormat:kDelimiter]];
 		miscString = [miscString stringByAppendingString:[NSString stringWithFormat:@"Dedication"]];
 		[self.rootViewController displayMiscMessage:miscString];
		return;
    }
	
	// check reachability
	BOOL networkReachable = [ProxyUtil networkReachable];
	if (!networkReachable) {
		[ProxyUtil showAlertNetworkUnreachable];
		return;
	}
	
	// let system prepare sb
	[self.search resignFirstResponder];
	
	// spawn a thread to fetch the entrez gene data so that the UI is not blocked while the application parses the XML file.
    [NSThread detachNewThreadSelector:@selector(getEntrezGeneData) toTarget:self withObject:nil];
	
	// start some animations - they will be stopped in getEntrezGene
	self.prefsButton.enabled = NO;
	self.infoButton.enabled = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.activityView.hidden = NO;
	[self.activityView startAnimating];
}

-(void)getEntrezGeneData {
	
	// this runs in its own thread, setup pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// clear out any previous search results
	[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(clearGeneList) withObject:nil waitUntilDone:YES];
	
	// create search url
	NSString *proxyURL = [ProxyUtil createSearchURL:search.text organism:self.rootViewController.prefs.organism retstart:kRetStartDefaultValue retmax:self.rootViewController.prefs.retMaxAbbr];
	
	// perform fetch
	NSError *parseError = nil;
	NSString *serverReturnCode = nil;
    ProxyReader *proxyReader = [[ProxyReader alloc] init];
	[proxyReader parseXMLFileAtURL:[NSURL URLWithString:proxyURL] parseError:&parseError serverReturnCode:&serverReturnCode];
	
	// end animations
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityView stopAnimating];
	self.activityView.hidden = YES;
	self.prefsButton.enabled = YES;
	self.infoButton.enabled = YES;
	
	// notify root view controller that search is complete
	if (parseError != nil) {
		// houston we have a problem - display parse error
		[ProxyUtil performSelectorOnMainThread:@selector(showAlertUnexpectedError) withObject:nil waitUntilDone:NO];
	}
	else {
		// update delegate with ret start
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(setRetstart:) withObject:kRetStartDefaultValue waitUntilDone:NO];
		// show search results
		NSString *query = [NSString stringWithFormat:@"%@:%@", self.search.text, serverReturnCode];
		[query retain];
		[self.rootViewController performSelectorOnMainThread:@selector(searchComplete:) withObject:query waitUntilDone:NO];
	}
	
	// release resources
	[proxyReader release];
	[pool release];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.search resignFirstResponder];
}

#pragma mark - UIWebView delegate

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	// capture user link click:
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *URL = [request URL];	
		if (![[UIApplication sharedApplication] openURL:URL]) {
			NSLog(@"%@%@",@"Failed to open url:",[URL description]);
		}
		// we return no because we don't want to load web page into web view, we will launch safari
		return NO;
	}
	return YES;   
}

@end
