//
//  NoResultsViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NoResultsViewController.h"
#import "constants.h"
#import "InterfaceUtil.h"
#import "RootViewController.h"

// class extension for private properties and methods
@interface NoResultsViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;

-(NSString *)createHTML;
-(NSString*)getValueFontSizeAsString;

@end

@implementation NoResultsViewController

@synthesize query;
@synthesize organism;
@synthesize serverReturnCode;
@synthesize uiWebView;
@synthesize rootViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = NSLocalizedString(kNoResultsViewControllerTitle, @"NoResultsViewController title");
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.uiWebView loadHTMLString:[self createHTML] baseURL:[NSURL URLWithString:@""]];
	[self.view insertSubview:self.uiWebView atIndex:0];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.uiWebView loadHTMLString:[self createHTML] baseURL:[NSURL URLWithString:@""]];
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
	[self.query release];
	[self.organism release];
	[self.serverReturnCode release];
	[self.uiWebView release];
	[self.rootViewController release];
    [super dealloc];
}

-(NSString *)createHTML {
	
	NSString *msg = nil;
	if ([serverReturnCode isEqualToString:kIDNotFoundCode]) {
		msg = [NSString stringWithFormat:kNoRecordsFound];
	}
	else if ([serverReturnCode isEqualToString:kFailureCode]) {
		msg = [NSString stringWithFormat:kErrorFetchingParsingData];
	}
	// should not get here
	else {
		msg = [NSString stringWithFormat:kInternalError];
	}
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:kNoResultsBaseStyle]];
	NSString *h1Style = [kCustomH1Style stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getValueFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:h1Style]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"<h1>%@</h1>" \
												  "<p>" \
												  "<h1>%@</h1>" \
												  "<font color=\"red\">%@</font>" \
												  "<p>" \
												  "<h1>%@</h1>" \
												  "<font color=\"red\">%@</font>",
												  msg,
												  kSearchTermHeading,
												  self.query,
												  kOrganismHeading,
												  self.organism]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"<p><h1>%@</h1>", kNoResultsFeedback]];
	toReturn = [toReturn stringByAppendingString:kHTMLHeaderClose];
	
	// outta here
	return toReturn;
}

-(NSString*)getValueFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", kBaseValueFontSize];
}

@end
