//
//  RIFViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RIFViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SwitchViewController.h"
#import "Gene.h"
#import "RIF.h"
#import "Prefs.h"
#import "constants.h"
#import "InterfaceUtil.h"
#import "ProxyUtil.h"

#define PREVIOUS_SEGMENT_INDEX 0
#define NEXT_SEGMENT_INDEX 1

// class extension for private properties and methods
@interface RIFViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;
@property NSInteger currentRIFPage;
@property NSInteger maxRIFPage;
@property (retain, nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *paginationLabel;

-(void)setRIFVars;
-(NSString *)createRIFHTML;
-(void)createSegmentedControl:(BOOL)createControl;
-(void)setSegmentButtons;
-(NSString*)getFontSizeAsString;
-(void)setPaginationLabel;

@end

@implementation RIFViewController

@synthesize switchViewController;
@synthesize uiWebView;
@synthesize currentRIFPage;
@synthesize maxRIFPage;
@synthesize fontSize;
@synthesize segmentedControl;
@synthesize paginationLabel;
@synthesize resetPagination;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[self setRIFVars];
	[self createSegmentedControl:YES];
	[self setSegmentButtons];
	
	// setup pagination label
	//self.paginationLabel.backgroundColor = [UIColor colorWithRed:0.94 green:0.96 blue:0.99 alpha:1.0];
	//self.paginationLabel.font = [UIFont boldSystemFontOfSize:19.0];
	//self.paginationLabel.textAlignment = UITextAlignmentCenter;
	self.paginationLabel.textColor = [UIColor blackColor];
	
	// we are webview delegate
	self.uiWebView.delegate = self;
	// we only detect hyperlinks (no phone numbers)
	self.uiWebView.dataDetectorTypes = UIDataDetectorTypeLink;
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.uiWebView loadHTMLString:[self createRIFHTML] baseURL:[NSURL URLWithString:@""]];
	[self.view insertSubview:self.uiWebView atIndex:0];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

	if (resetPagination) {
		[self setRIFVars];
		resetPagination = NO;
	}
	[self createSegmentedControl:NO];	
	[self setSegmentButtons];
	[self setPaginationLabel];
	[self.uiWebView loadHTMLString:[self createRIFHTML] baseURL:[NSURL URLWithString:@""]];
}

- (void)viewWillDisappear:(BOOL)animated {

	self.switchViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[self.segmentedControl release];
	[self.switchViewController release];
	[self.uiWebView release];
	[self.paginationLabel release];
    [super dealloc];
}

- (void)setRIFVars {
	
	// first time view loads, we are at gene/rif 0
	self.currentRIFPage = 0;
	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	NSInteger rifCount = [gene.rifList count];
	NSInteger numRifsPerPage = self.switchViewController.rootViewController.prefs.rifsPerPageInteger;
	self.maxRIFPage = rifCount / numRifsPerPage;
	if (self.maxRIFPage * numRifsPerPage + numRifsPerPage < rifCount) {
		++self.maxRIFPage;
	}
}

-(void)setPaginationLabel {
	
	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	
	if ([gene.rifList count] == 0) {
		self.paginationLabel.backgroundColor = [UIColor whiteColor];
		self.paginationLabel.font = [UIFont systemFontOfSize:self.fontSize];
		self.paginationLabel.textAlignment = NSTextAlignmentLeft;
		self.paginationLabel.text = [NSString stringWithFormat:kSpace];
		self.paginationLabel.text = [self.paginationLabel.text stringByAppendingString:kSpace];
		self.paginationLabel.text = [self.paginationLabel.text stringByAppendingString:kNoRIFs];
		//self.paginationLabel.text = [NSString stringWithFormat:kNoRIFs];
	}
	else {
		NSInteger numRifsPerPage = self.switchViewController.rootViewController.prefs.rifsPerPageInteger;
		NSInteger startIndex = self.currentRIFPage * numRifsPerPage;
		NSInteger totalNumberRIFs = [gene.rifList count];
	
		// get record start (add one since we start from zero)
		NSString *retStart = [NSString stringWithFormat:@"%i", startIndex + 1];
	
		// number of records in table - the number we are display
		NSInteger numRifsDisplay = ((startIndex + numRifsPerPage) < totalNumberRIFs) ? (startIndex + numRifsPerPage) : totalNumberRIFs;
		NSString *numberOfRows = [NSString stringWithFormat:@"%i", numRifsDisplay];
	
		// total records
		NSString *countStr = [NSString stringWithFormat:@"%i", totalNumberRIFs];
	
		// set label
		self.paginationLabel.backgroundColor = [UIColor colorWithRed:0.94 green:0.96 blue:0.99 alpha:1.0];
		self.paginationLabel.font = [UIFont boldSystemFontOfSize:19.0];
		self.paginationLabel.textAlignment = NSTextAlignmentCenter;
		self.paginationLabel.text = [InterfaceUtil getPaginationString:NO start:retStart end:numberOfRows total:countStr];
	}
}

-(void)createSegmentedControl:(BOOL)createControl {
	
	// setup segment control
	if (createControl) {
		self.segmentedControl = [[UISegmentedControl alloc] initWithItems:
								 [NSArray arrayWithObjects:
								 [UIImage imageNamed:@"up.png"],
								 [UIImage imageNamed:@"down.png"],
								  nil]];
		[self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.segmentedControl.frame = CGRectMake(0, 0, 90, 30);
		self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		self.segmentedControl.momentary = YES;
	}
	
	UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl] autorelease];
	self.switchViewController.navigationItem.rightBarButtonItem = segmentBarItem;
}

- (void)segmentAction:(id)sender {

	NSInteger selectedIndex = [self.segmentedControl selectedSegmentIndex];
	
	if (selectedIndex == PREVIOUS_SEGMENT_INDEX) {
		if (--self.currentRIFPage < 0) {
			self.currentRIFPage = 0;
		}
	}
	else if (++self.currentRIFPage > self.maxRIFPage) {
		self.currentRIFPage = self.maxRIFPage;
	}
	
	[self setSegmentButtons];
	[self setPaginationLabel];
	[self.uiWebView loadHTMLString:[self createRIFHTML] baseURL:[NSURL URLWithString:@""]];
}

- (void)setSegmentButtons {
	
	// set buttons appropriately
	BOOL enablePrevButton = !(self.currentRIFPage == 0);
	[self.segmentedControl setEnabled:enablePrevButton forSegmentAtIndex:PREVIOUS_SEGMENT_INDEX];
	BOOL enableNextButton = !(self.currentRIFPage == self.maxRIFPage);
	[self.segmentedControl setEnabled:enableNextButton forSegmentAtIndex:NEXT_SEGMENT_INDEX];
}

-(BOOL)fontSizeIncrease:(BOOL)redraw {
	
	BOOL enable = YES;
	if (++self.fontSize >= kMaxBaseFontSize) {
		self.fontSize = kMaxBaseFontSize;
		enable = NO;
	}
	if (redraw) {
		[self viewWillAppear:NO];
	}
	
	// outta here
	return enable;
}

-(BOOL)fontSizeDecrease:(BOOL)redraw {
	
	BOOL enable = YES;
	if (--self.fontSize <= kMinBaseFontSize) {
		self.fontSize = kMinBaseFontSize;
		enable = NO;
	}
	if (redraw) {
		[self viewWillAppear:NO];
	}
	
	// outta here
	return enable;
}

-(NSString*)getFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", self.fontSize];
}

-(NSString *)createRIFHTML {
	
	NSInteger numRifsPerPage = self.switchViewController.rootViewController.prefs.rifsPerPageInteger;
	NSInteger startIndex = self.currentRIFPage * numRifsPerPage;
	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];
	// replace base style font size property
	NSString *style = [kRIFBaseStyle stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:style]];
	id element;
	NSEnumerator *enm = [gene.rifList objectEnumerator];
	int counter = -1;
	while (element = [enm nextObject]) {
		++counter;
		if (counter < startIndex) continue;
		if (counter == (startIndex + numRifsPerPage)) break;
		RIF *rif = (RIF *)element;
		toReturn = (rif.rif != nil && [rif.rif length] > 0) ?
			[toReturn stringByAppendingString:[NSString stringWithFormat:
											   @"<ul>" \
											   "<li>" \
											   "%@" \
											   "&nbsp<a href=\"http://www.ncbi.nlm.nih.gov/pubmed/" \
											   "%@" \
											   "%@" \
											   "\">[Abstract]</a>" \
											   "</ul>", rif.rif, rif.pubmedID, kPubMedReportAndFormat]] :
			[toReturn stringByAppendingString:[NSString stringWithFormat:kNoRIFInfo]];
	}
	// no rifs handled in pagination label
	//if (counter == -1) {
	//	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:kNoRIFs]];
	//}
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:kHTMLHeaderClose]];
	return toReturn;
}

#pragma mark - UIWebView delegate

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	// capture user link click:
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = [request URL];	
		if ([[url scheme] isEqualToString:@"http"]) {
			
			// check reachability
			BOOL networkReachable = [ProxyUtil networkReachable];
			if (!networkReachable) {
				[ProxyUtil showAlertNetworkUnreachable];
				return NO;
			}
			
			// we are reachable, display pubmed view
			[self.switchViewController pubMedView:nil url:url];
		}	 
	}	
	return YES;
}

@end
