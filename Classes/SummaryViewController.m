//
//  SummaryViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"
#import "AppDelegate.h"
#import "Gene.h"
#import "constants.h"
#import "ProxyUtil.h"

// class extension for private properties and methods
@interface SummaryViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;

-(NSString*)getValueFontSizeAsString;
-(NSString*)getHeaderFontSizeAsString;
-(NSString *)createSummaryHTML;

@end

@implementation SummaryViewController

@synthesize valueFontSize;
@synthesize headerFontSize;
@synthesize uiWebView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//self.valueFontSize = kBaseValueFontSize;
	//self.headerFontSize = kBaseHeaderFontSize;
	
	// we are webview delegate
	self.uiWebView.delegate = self;
	// we only detect hyperlinks (no phone numbers)
	self.uiWebView.dataDetectorTypes = UIDataDetectorTypeLink;
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.uiWebView loadHTMLString:[self createSummaryHTML] baseURL:[NSURL URLWithString:@""]];
	[self.view insertSubview:self.uiWebView atIndex:0];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.uiWebView loadHTMLString:[self createSummaryHTML] baseURL:[NSURL URLWithString:@""]];
}

//- (void)viewDidDisappear:(BOOL)animated {
-(void)clearScreen {
	// load blank data into webview, we do this because sometime we see old data when reloading this view
	[self.uiWebView loadHTMLString:@"" baseURL:[NSURL URLWithString:@""]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    self.uiWebView.delegate = nil;
	[self.uiWebView release];
    [super dealloc];
}

-(BOOL)fontSizeIncrease:(BOOL)redraw {
	
	BOOL enable = YES;
	if (++self.headerFontSize >= kMaxHeaderFontSize) {
		self.headerFontSize = kMaxHeaderFontSize;
		enable = NO;
	}
	if (++self.valueFontSize >= kMaxValueFontSize) {
		self.valueFontSize = kMaxValueFontSize;
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
	if (--self.headerFontSize <= kMinHeaderFontSize) {
		self.headerFontSize = kMinHeaderFontSize;
		enable = NO;
	}
	if (--self.valueFontSize <= kMinValueFontSize) {
		self.valueFontSize = kMinValueFontSize;
		enable = NO;
	}
	if (redraw) {
		[self viewWillAppear:NO];
	}
	
	// outta here
	return enable;
}

-(NSString*)getHeaderFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", self.headerFontSize];
}

-(NSString*)getValueFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", self.valueFontSize];
}

-(NSString *)createSummaryHTML {
	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:kSummaryBaseStyle]];
	
	// replace header font size property
	NSString *h1Style = [kCustomH1Style stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getHeaderFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:h1Style]];

	// replace value font size property
	NSString *h2Style = [kCustomH2SummaryStyle stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getValueFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:h2Style]];
	
	// setup locus tag
	NSString *locusTag = nil;
	if (gene.tag != nil && [gene.tag length] > 0) {
		locusTag = [NSString stringWithFormat:@"<tr><td><h2><b>%@</b>%@</h2></td></tr>", kLocusTag, gene.tag];
	}
	
	// setup mim
	NSString *mim = nil;
	if (gene.organism != nil && [gene.organism isEqualToString:kHomesapiens]) {
		if (gene.mim != nil && [gene.mim length] > 0) {
			mim = [NSString stringWithFormat:@"<tr><td><h2><b>%@</b><a href=\"http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=%@\">%@</a></h2></td></tr>", kMIMHeading, gene.mim, gene.mim];
		}
		else {
			mim = [NSString stringWithFormat:@"<tr><td><h2><b>%@</b>%@</h2></td></tr>", kMIMHeading, kNoMIM];
		}
	}
	
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:
												  @"<table>" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "%@" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "%@" \
												  "<tr>" \
												  "<td><h2><b>%@</b>%@</h2></td>" \
												  "</tr>" \
												  "</table>",
												  kOfficialSymbolHeading,
												  (gene.symbol != nil && [gene.symbol length] > 0) ? gene.symbol : [NSString stringWithFormat:kNoSymbol],
												  kName,
												  (gene.description != nil && [gene.description length] > 0) ? gene.description : [NSString stringWithFormat:kNoName],
												  (locusTag != nil) ? locusTag : [NSString stringWithFormat:@""],
												  kAliasesHeading,
												  (gene.aliases != nil && [gene.aliases length] > 0) ? gene.aliases : [NSString stringWithFormat:kNoAliases],
												  kSummaryOrganismHeading,
  												  (gene.organism != nil && [gene.organism length] > 0) ? gene.organism : [NSString stringWithFormat:kNoOrganism],
												  kDesignationsHeading,
												  (gene.designations != nil && [gene.designations length] > 0) ? gene.designations : kNoDesignation,
												  kChromosomeHeading,
												  (gene.location != nil && [gene.location length] > 0) ? gene.location : [NSString stringWithFormat:kNoLocation],
												  (mim != nil) ? mim : [NSString stringWithFormat:@""],
												  kGeneIDHeading,
												  (gene.geneID != nil && [gene.geneID length] > 0) ? gene.geneID : kNoGeneID]];
	
	toReturn = [toReturn stringByAppendingString:kHTMLHeaderClose];
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
			
			[[UIApplication sharedApplication] openURL:url];
		}	 
	}	
    return YES;
}

@end
