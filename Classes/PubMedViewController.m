//
//  PubMedViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PubMedViewController.h"
#import "SwitchViewController.h"
#import "RootViewController.h"
#import "constants.h"
#import "InterfaceUtil.h"
#import "ProxyUtil.h"

#define TEXT_SMALL_SEGMENT 0
#define TEXT_LARGE_SEGMENT 1

// class extension for private properties and methods
@interface PubMedViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *uiFontSizeSegmentedControl;
@property (nonatomic, retain) UIWebView *uiWebView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSString *abstractPlus;

-(NSString*)getFontSizeAsString;
-(NSString*)getHeaderFontSizeAsString;
-(void)loadWebView;
-(NSString *)createPubMedHTML;
-(void)loadAbstractPlus;

@end

@implementation PubMedViewController

@synthesize titleLabel;
@synthesize uiWebView;
@synthesize fontSize;
@synthesize headerFontSize;
@synthesize url;
@synthesize activityView;
@synthesize rootViewController;
@synthesize switchViewController;
@synthesize abstractPlus;
@synthesize uiFontSizeSegmentedControl;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// set base font sizes
	//self.fontSize = kBaseValueFontSize;
	//self.headerFontSize = kBaseHeaderFontSize;
	
	// we only detect hyperlinks (no phone numbers)
	self.uiWebView.dataDetectorTypes = UIDataDetectorTypeNone;
	
	// setup label
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
	self.titleLabel.text = NSLocalizedString(kPubMedViewControllerTitle, @"PubMedViewController title");
	
	// setup activity view
	CGRect activityViewRect = CGRectMake(kPubMedActivityViewX, kPubMedActivityViewY, kActivityViewWidth, kActivityViewHeight);
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:activityViewRect];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	self.activityView.hidden = YES;	
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.activityView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
										  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    // listen to rotation events
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
	
	// insert uiWebView into our view stack
	[self.view insertSubview:uiWebView atIndex:0];
	// we want activity indicator at top
	[self.view insertSubview:self.activityView atIndex:1];
	
    [uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_SMALL_SEGMENT];
    [uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_LARGE_SEGMENT];

    
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	//[uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_SMALL_SEGMENT];
	//[uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_LARGE_SEGMENT];
	
	// start activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.activityView.hidden = NO;
	[self.activityView startAnimating];
	
	// get abstract from pubmed
	[self loadAbstractPlus];
	// load webview
	[self loadWebView];
}

-(void)loadWebView {
	// load webview
	[self.uiWebView loadHTMLString:[self createPubMedHTML] baseURL:[NSURL URLWithString:@""]];
	
	// we seem to have to do this after loading webView content otherwise it does not get displayed
	[self.view insertSubview:self.uiWebView atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
	// end activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityView stopAnimating];
	self.activityView.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	// load blank data into webview, we do this because sometime we see old data when reloading this view
	[self.uiWebView loadHTMLString:@"" baseURL:[NSURL URLWithString:@""]];
	[self.uiWebView removeFromSuperview];
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    return ([InterfaceUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation prefs:self.rootViewController.prefs]);
}

/*
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSLog(@"Our orientation has changed");
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[self.title release];
	[self.uiWebView release];
	[self.url release];
	[self.activityView release];
	[self.rootViewController release];
	[self.switchViewController release];
	[self.abstractPlus release];
	[self.uiFontSizeSegmentedControl release];
    [super dealloc];
}

-(IBAction)close:(id)sender {
	[self.switchViewController closePubMed];
}

-(IBAction)gotoPubMed:(id)sender {

	NSString *pubMedURLStr = [[self.url absoluteString] stringByReplacingOccurrencesOfString:kPubMedReportAndFormat withString:@""];
	NSURL *pubMedURL = [NSURL URLWithString:pubMedURLStr];
	
	// check reachability
	BOOL networkReachable = [ProxyUtil networkReachable];
	if (!networkReachable) {
		[ProxyUtil showAlertNetworkUnreachable];
		return;
	}
	
	// network reachable
	[[UIApplication sharedApplication] openURL:pubMedURL];
}

-(IBAction)fontSizeSegmentAction:(id)sender {
	
	if ([sender selectedSegmentIndex] == TEXT_SMALL_SEGMENT) {
		[self.switchViewController fontSizeSegmentAction:sender];
	}
	else if ([sender selectedSegmentIndex] == TEXT_LARGE_SEGMENT) {
		[self.switchViewController fontSizeSegmentAction:sender];
	}
}

-(BOOL)fontSizeIncrease:(BOOL)redraw {
	
	BOOL enable = YES;
	if (++self.headerFontSize >= kMaxHeaderFontSize) {
		self.headerFontSize = kMaxHeaderFontSize;
		enable = NO;
	}
	if (++self.fontSize >= kMaxValueFontSize) {
		self.fontSize = kMaxValueFontSize;
		enable = NO;
	}
	if (redraw) {
		[self loadWebView];
	}
	
	// update segment button state
	[uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_SMALL_SEGMENT];
	[uiFontSizeSegmentedControl setEnabled:enable forSegmentAtIndex:TEXT_LARGE_SEGMENT];
	
	// outta here
	return enable;
}

-(BOOL)fontSizeDecrease:(BOOL)redraw {
	
	BOOL enable = YES;
	if (--self.headerFontSize <= kMinHeaderFontSize) {
		self.headerFontSize = kMinHeaderFontSize;
		enable = NO;
	}
	if (--self.fontSize <= kMinValueFontSize) {
		self.fontSize = kMinValueFontSize;
		enable = NO;
	}
	if (redraw) {
		[self loadWebView];
	}
	
	// update segment button state
	[uiFontSizeSegmentedControl setEnabled:enable forSegmentAtIndex:TEXT_SMALL_SEGMENT];
	[uiFontSizeSegmentedControl setEnabled:YES forSegmentAtIndex:TEXT_LARGE_SEGMENT];
	
	// outta here
	return enable;
}

-(NSString*)getFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", self.fontSize];
}

-(NSString*)getHeaderFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", self.headerFontSize];
}

-(NSString *)createPubMedHTML {

	// string to return
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];

	// replace base style font size property
	NSString *style = [kFunctionBaseStyle stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:style]];
	
	// replace header font size property
	NSString *h1Style = [kCustomH1Style stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getHeaderFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:h1Style]];
	
	toReturn = (self.abstractPlus != nil && [abstractPlus length] > 0) ?
		[toReturn stringByAppendingString:abstractPlus] :
		[toReturn stringByAppendingString:kNoPubMedAbstract];
	toReturn = [toReturn stringByAppendingString:kHTMLHeaderClose];
	
	return toReturn;
}

-(void)loadAbstractPlus {
	
	// this will be used below
	self.abstractPlus = [NSString string];
	
	// get abstract from pubmed
	NSData *data = [NSData dataWithContentsOfURL:self.url];
	NSString *rawAbstract = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (rawAbstract == nil || [rawAbstract length] == 0) return;
	
	// strip out xml
	NSRange startRange = [rawAbstract rangeOfString:@"<pre>"];
	NSRange endRange = [rawAbstract rangeOfString:@"</pre>"];
	NSUInteger startLoc = startRange.location + startRange.length;
	NSUInteger startLen = endRange.location - startLoc;
	if (startLen == 0) return;
	NSRange range = NSMakeRange(startLoc, startLen);
	NSString *abstract = [rawAbstract substringWithRange:range];
	[rawAbstract release];
	
	// Replace blank line '\n\n' with <br><br>, we use loop insteod
	// of stringByReplacingOccurencesOfString so we can also drop last line
	// which erroneously becomes a link by stringWithContentsOfURL method.
	// We can drop this last line because it just contains the PMID which is not needed:
	// PMID: 19082758 [PubMed - indexed for MEDLINE]
	NSArray *abstractLines = [abstract componentsSeparatedByString:@"\n\n"];
	id element;
	NSEnumerator *enm = [abstractLines objectEnumerator];
	int counter = 0;
	int numLines = [abstractLines count];
	if (numLines == 0) {
		self.abstractPlus = [self.abstractPlus stringByAppendingString:abstract];
		[abstract release];
		return;
	}
	while (element = [enm nextObject]) {
		++counter;
		if (counter == 2) {
			self.abstractPlus = [self.abstractPlus stringByAppendingString:@"<b>"];
		}
		NSString *line = (NSString *)element;
		self.abstractPlus = [self.abstractPlus stringByAppendingString:line];
			
		if (counter == 2) {
			self.abstractPlus = [self.abstractPlus stringByAppendingString:@"</b>"];
		}
		if (counter < numLines) {
			self.abstractPlus = [self.abstractPlus stringByAppendingString:[NSString stringWithFormat:@"<br><br>"]];
		}
	}

	// replace single '\n' with ' '
	self.abstractPlus = [self.abstractPlus stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	// add blank line at bottom
	self.abstractPlus = [self.abstractPlus stringByAppendingString:@"<br>"];
}

@end
