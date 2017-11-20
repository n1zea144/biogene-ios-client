//
//  FunctionViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FunctionViewController.h"
#import "AppDelegate.h"
#import "Gene.h"
#import "constants.h"

// class extension for private properties and methods
@interface FunctionViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *uiWebView;

-(NSString *)createFunctionHTML;
-(NSString*)getFontSizeAsString;

@end

@implementation FunctionViewController

@synthesize uiWebView;
@synthesize fontSize;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// we only detect hyperlinks (no phone numbers)
	self.uiWebView.dataDetectorTypes = UIDataDetectorTypeLink;
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.uiWebView.autoresizesSubviews = YES;
	self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.uiWebView loadHTMLString:[self createFunctionHTML] baseURL:[NSURL URLWithString:@""]];
	[self.view insertSubview:uiWebView atIndex:0];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.uiWebView loadHTMLString:[self createFunctionHTML] baseURL:[NSURL URLWithString:@""]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[self.uiWebView release];
    [super dealloc];
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
	return [NSString stringWithFormat:@"%lipx", (long)self.fontSize];
}

-(NSString *)createFunctionHTML {

	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	NSString *toReturn = [NSString stringWithFormat:kHTMLHeader];

	// replace base style font size property
	NSString *style = [kFunctionBaseStyle stringByReplacingOccurrencesOfString:kFontSizePlaceHolder withString:[self getFontSizeAsString]];
	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"%@", style]];
	
	toReturn = (gene.summary != nil && [gene.summary length] > 0) ?
		[toReturn stringByAppendingString:gene.summary] :
		[toReturn stringByAppendingString:kNoFunctionDescription];
	toReturn = [toReturn stringByAppendingString:kHTMLHeaderClose];
	return toReturn;
}

@end
