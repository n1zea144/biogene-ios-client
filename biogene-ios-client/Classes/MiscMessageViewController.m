//
//  MiscMessageViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MiscMessageViewController.h"
#import "constants.h"
#import "InterfaceUtil.h"
#import "RootViewController.h"

// class extension for private properties and methods
@interface MiscMessageViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;

-(NSString *)createHTML;
-(NSString*)getValueFontSizeAsString;

@end

@implementation MiscMessageViewController

@synthesize displayTitle;
@synthesize displayMessage;
@synthesize uiWebView;
@synthesize rootViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//self.title = NSLocalizedString(kMiscMessageViewControllerTitle, @"MiscMessageViewController title");
	self.title = NSLocalizedString(self.displayTitle, @"MiscMessageViewController title");
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[uiWebView loadHTMLString:[self createHTML] baseURL:[NSURL URLWithString:@""]];
	[self.view insertSubview:uiWebView atIndex:0];
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
	[self.uiWebView release];
	[self.displayTitle release];
	[self.displayMessage release];
	[self.rootViewController release];
    [super dealloc];
}

-(NSString *)createHTML {
	
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:kMiscMesgBaseStyle]];
	NSString *h1Style = [kCustomH1Style stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getValueFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:h1Style]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"<h1><font color=\"black\">%@</font></h1>", self.displayMessage]];
	toReturn = [toReturn stringByAppendingString:kHTMLHeaderClose];
	return toReturn;
}

-(NSString*)getValueFontSizeAsString {
	return [NSString stringWithFormat:@"%ipx", kBaseValueFontSize];
}

@end
