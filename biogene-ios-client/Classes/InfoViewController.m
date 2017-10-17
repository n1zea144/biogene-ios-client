//
//  InfoViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "RootViewController.h"
#import "InterfaceUtil.h"
#import "constants.h"

// class extension for private properties and methods
@interface InfoViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) UIWebView *uiWebView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end

@implementation InfoViewController

@synthesize titleLabel;
@synthesize request;
@synthesize uiWebView;
@synthesize activityView;
@synthesize rootViewController;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[self.titleLabel release];
	[self.request release];
	[self.uiWebView release];
	[self.activityView release];
	[self.rootViewController release];
	[super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// setup label
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
	self.titleLabel.text = NSLocalizedString(kInfoViewControllerTitle, @"InfoViewController title");
	
	// we are uiwebview delegate
	self.uiWebView.delegate = self;
	self.uiWebView.scalesPageToFit = YES;
	
	// setup activity view
	CGRect activityViewRect = CGRectMake(kInfoViewActivityViewX, kInfoViewActivityViewY, kActivityViewWidth, kActivityViewHeight);
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
	
	// insert uiWebView into our view stack
	[self.view insertSubview:uiWebView atIndex:0];
	// we want activity indicator at top
	[self.view insertSubview:self.activityView atIndex:1];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.activityView.hidden = NO;
	[self.activityView startAnimating];
	[self.uiWebView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.uiWebView removeFromSuperview];
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    return ([InterfaceUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation prefs:self.rootViewController.prefs]);
}

//
// close button action
//
-(IBAction)close:(id)sender {
	[self.rootViewController infoView];
}


#pragma mark UIWebView delegate methods

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityView stopAnimating];
	self.activityView.hidden = YES;
	[self.view insertSubview:uiWebView atIndex:0];
}

@end
