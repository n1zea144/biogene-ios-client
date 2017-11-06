//
//  SwitchViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwitchViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SummaryViewController.h"
#import "FunctionViewController.h"
#import "RIFViewController.h"
#import "PubMedViewController.h"
#import "Gene.h"
#import "constants.h"
#import "InterfaceUtil.h"

#define SUMMARY_SEGMENT 0
#define FUNCTION_SEGMENT 1
#define RIF_SEGMENT 2

#define TEXT_SMALL_SEGMENT 0
#define TEXT_LARGE_SEGMENT 1

@interface SwitchViewController ()

@property (retain, nonatomic) RIFViewController *rifViewController;
@property (retain, nonatomic) PubMedViewController *pubMedViewController;
@property (retain, nonatomic) SummaryViewController *summaryViewController;
@property (retain, nonatomic) FunctionViewController *functionViewController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *uiFontSizeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *uiSwitchViewSegmentedControl;
@property BOOL pubMedViewJustOpened;
@property BOOL pubMedViewJustClosed;

-(void)summaryView:(id)sender;
-(void)functionView:(id)sender;
-(void)rifView:(id)sender duration:(NSTimeInterval)duration transition:(UIViewAnimationTransition)transition;
-(UIViewController*)getCurrentViewController;
-(void)switchView:(UIViewController*)currentViewController newViewController:(UIViewController*)newViewController duration:(NSTimeInterval)duration transition:(UIViewAnimationTransition)transition;
-(void)setFontSizeSegmentButtons:(BOOL)enableFontSizeDecreaseButton enableFontSizeIncreaseButton:(BOOL)enableFontSizeIncreaseButton;

@end

@implementation SwitchViewController

@synthesize rootViewController;
@synthesize summaryViewController;
@synthesize functionViewController;
@synthesize rifViewController;
@synthesize pubMedViewController;
@synthesize uiSwitchViewSegmentedControl;
@synthesize uiFontSizeSegmentedControl;
@synthesize pubMedViewJustClosed;
@synthesize pubMedViewJustOpened;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// create summary view
	SummaryViewController *summaryController = [[SummaryViewController alloc] initWithNibName:@"SummaryView" bundle:nil];
	self.summaryViewController = summaryController;
	self.summaryViewController.valueFontSize = kBaseValueFontSize;
	self.summaryViewController.headerFontSize = kBaseHeaderFontSize;
	[summaryController release];
	
	/// create function view - now created so we can keep track of font size
	FunctionViewController *functionController = [[FunctionViewController alloc] initWithNibName:@"FunctionView" bundle:nil];
	self.functionViewController = functionController;
	self.functionViewController.fontSize = kBaseFontSize;
	[functionController release];
	
	// create rif view - now created so we can keep track of font size
	RIFViewController *rifController = [[RIFViewController alloc] initWithNibName:@"RIFView" bundle:nil];
	self.rifViewController = rifController;
	self.rifViewController.fontSize = kBaseFontSize;
	self.rifViewController.switchViewController = self;
	[rifController release];
	
	// create pub med view - now created so we can keep track of font size
	PubMedViewController *pubMedController = [[PubMedViewController alloc]initWithNibName:@"PubMedView" bundle:nil];
	self.pubMedViewController = pubMedController;
	//self.pubMedViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	self.pubMedViewController.switchViewController = self;
	self.pubMedViewController.rootViewController = self.rootViewController;
	self.pubMedViewController.fontSize = kBaseValueFontSize;
	self.pubMedViewController.headerFontSize = kBaseHeaderFontSize;
	[pubMedController release];
	
	// this does not appear necessary, but I feel better if its here
	[self setFontSizeSegmentButtons:YES enableFontSizeIncreaseButton:YES];
        
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	Gene *gene = [(id)[[UIApplication sharedApplication] delegate] getGeneOfInterest];
	NSString *geneSymbol = [InterfaceUtil getGeneSymbol:gene];
	self.title = (geneSymbol != nil) ?
				  NSLocalizedString(geneSymbol, @"SwitchViewController title") :
				  NSLocalizedString(kSwitchViewControllerTitle, @"SwitchViewController title");

	// these lines are required if orientation changed in one view and we are now switching to another
	CGRect curFrame = self.view.frame;
	[self.summaryViewController.view setFrame:curFrame];
	
	if (self.pubMedViewJustClosed) {
		self.pubMedViewJustClosed = NO;
		[self.view insertSubview:self.rifViewController.view atIndex:0];
		self.uiSwitchViewSegmentedControl.selectedSegmentIndex = RIF_SEGMENT;
	}
	// by default always start at summary view
	else {
		[self.summaryViewController viewWillAppear:NO];
		[self.view insertSubview:self.summaryViewController.view atIndex:0];
		self.uiSwitchViewSegmentedControl.selectedSegmentIndex = SUMMARY_SEGMENT;
		// rifview controller does not always get viewWillDisappear, make sure right bar button item is nil
		self.navigationItem.rightBarButtonItem = nil;
		// we want rifs to start at page 1
		self.rifViewController.resetPagination = YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.summaryViewController clearScreen];
	UIViewController *currentViewController = [self getCurrentViewController];
	[currentViewController.view removeFromSuperview];
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
	[self.rootViewController release];
	[self.summaryViewController release];
	[self.functionViewController release];
	[self.rifViewController release];
	[self.pubMedViewController release];
	[self.uiSwitchViewSegmentedControl release];
	[self.uiFontSizeSegmentedControl release];
    [super dealloc];
}

-(IBAction)switchViewSegmentAction:(id)sender {

	if ([sender selectedSegmentIndex] == SUMMARY_SEGMENT) {
		[self summaryView:sender];
	}
	else if ([sender selectedSegmentIndex] == FUNCTION_SEGMENT) {
		[self functionView:sender];
	}
	else if ([sender selectedSegmentIndex] == RIF_SEGMENT) {
		[self rifView:sender duration:1.0 transition:UIViewAnimationTransitionCurlUp];
	}
}

-(IBAction)fontSizeSegmentAction:(id)sender {
	
	BOOL enableDecreaseButton = YES;
	BOOL enableIncreaseButton = YES;
	UIViewController *currentViewController = [self getCurrentViewController];

	if ([sender selectedSegmentIndex] == TEXT_SMALL_SEGMENT) {
		if (currentViewController == self.summaryViewController) {
			enableDecreaseButton = [self.summaryViewController fontSizeDecrease:YES];
			[self.functionViewController fontSizeDecrease:NO];
			[self.rifViewController fontSizeDecrease:NO];
			[self.pubMedViewController fontSizeDecrease:NO];
		}
		else if (currentViewController == self.functionViewController) {
			enableDecreaseButton = [self.functionViewController fontSizeDecrease:YES];
			[self.summaryViewController fontSizeDecrease:NO];
			[self.rifViewController fontSizeDecrease:NO];
			[self.pubMedViewController fontSizeDecrease:NO];
		}
		else if (currentViewController == self.rifViewController) {
			enableDecreaseButton = [self.rifViewController fontSizeDecrease:true];
			[self.summaryViewController fontSizeDecrease:NO];
			[self.functionViewController fontSizeDecrease:NO];
			[self.pubMedViewController fontSizeDecrease:NO];
		}
		else {
			enableDecreaseButton = [self.pubMedViewController fontSizeDecrease:true];
			[self.summaryViewController fontSizeDecrease:NO];
			[self.functionViewController fontSizeDecrease:NO];
			[self.rifViewController fontSizeDecrease:NO];
			// this line needed to fix a cosmetic issue which
			// results from font size being changed in pubMed
			// and user seeing redraw of rifView upon exit of pubMedView
			[self.rifViewController viewWillAppear:NO]; 
		}
	}
	else if ([sender selectedSegmentIndex] == TEXT_LARGE_SEGMENT) {
		if (currentViewController == self.summaryViewController) {
			enableIncreaseButton = [self.summaryViewController fontSizeIncrease:YES];
			[self.functionViewController fontSizeIncrease:NO];
			[self.rifViewController fontSizeIncrease:NO];
			[self.pubMedViewController fontSizeIncrease:NO];
		}
		else if (currentViewController == self.functionViewController) {
			enableIncreaseButton = [self.functionViewController fontSizeIncrease:YES];
			[self.summaryViewController fontSizeIncrease:NO];
			[self.rifViewController fontSizeIncrease:NO];
			[self.pubMedViewController fontSizeIncrease:NO];
		}
		else if (currentViewController == self.rifViewController) {
			enableIncreaseButton = [self.rifViewController fontSizeIncrease:YES];
			[self.summaryViewController fontSizeIncrease:NO];
			[self.functionViewController fontSizeIncrease:NO];
			[self.pubMedViewController fontSizeIncrease:NO];
		}
		else {
			enableIncreaseButton = [self.pubMedViewController fontSizeIncrease:YES];
			[self.summaryViewController fontSizeIncrease:NO];
			[self.functionViewController fontSizeIncrease:NO];
			[self.rifViewController fontSizeIncrease:NO];
			// this line needed to fix a cosmetic issue which
			// results from font size being changed in pubMed
			// and user seeing redraw of rifView upon exit of pubMedView
			[self.rifViewController viewWillAppear:NO];
		}
	}
	[self setFontSizeSegmentButtons:enableDecreaseButton enableFontSizeIncreaseButton:enableIncreaseButton];
}

-(void)setFontSizeSegmentButtons:(BOOL)enableFontSizeDecreaseButton enableFontSizeIncreaseButton:(BOOL)enableFontSizeIncreaseButton {
	
	// set buttons appropriately
	[uiFontSizeSegmentedControl setEnabled:enableFontSizeDecreaseButton forSegmentAtIndex:TEXT_SMALL_SEGMENT];
	[uiFontSizeSegmentedControl setEnabled:enableFontSizeIncreaseButton forSegmentAtIndex:TEXT_LARGE_SEGMENT];
}


-(void)summaryView:(id)sender {

	if (self.summaryViewController.view.superview == nil) {
		[self switchView:[self getCurrentViewController] newViewController:self.summaryViewController duration:1.0 transition:UIViewAnimationTransitionCurlUp];
	}
	else {
		[self.summaryViewController viewWillAppear:YES];
	}
}

-(void)functionView:(id)sender {
	
	if (self.functionViewController.view.superview == nil) {
		[self switchView:[self getCurrentViewController] newViewController:self.functionViewController duration:1.0 transition:UIViewAnimationTransitionCurlUp];
	}
}

-(void)rifView:(id)sender duration:(NSTimeInterval)duration transition:(UIViewAnimationTransition)transition {
	
	if (self.rifViewController.view.superview == nil) {
		[self switchView:[self getCurrentViewController] newViewController:self.rifViewController duration:duration transition:transition];
	}
}

-(void)pubMedView:(id)sender url:(NSURL *)url {

	self.pubMedViewController.url = url;
    if (self.pubMedViewJustOpened == NO) {
        [self presentViewController:self.pubMedViewController animated:YES completion:nil];
        self.pubMedViewJustOpened = YES;
    }
}

-(UIViewController*)getCurrentViewController {
	if (self.summaryViewController != nil && self.summaryViewController.view.superview != nil) return self.summaryViewController;
	if (self.functionViewController != nil && self.functionViewController.view.superview != nil) return self.functionViewController;
	if (self.rifViewController != nil && self.rifViewController.view.superview != nil) return self.rifViewController;
	return nil;
}

-(void)switchView:(UIViewController*)currentViewController newViewController:(UIViewController*)newViewController duration:(NSTimeInterval)duration transition:(UIViewAnimationTransition)transition {

	// these lines are required if orientation changed in one view and we are now switching to another
	//CGRect curFrame = [[UIScreen mainScreen] applicationFrame];
	CGRect curFrame = currentViewController.view.frame;
	[newViewController.view setFrame:curFrame];
	
	//[UIView beginAnimations:@"View Flip" context:nil];
	//[UIView setAnimationDuration:duration];
	//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	//[UIView setAnimationTransition:transition forView:self.view cache:NO];
	[currentViewController viewWillDisappear:YES];
	[currentViewController.view removeFromSuperview];
	[currentViewController viewDidDisappear:YES];
	[newViewController viewWillAppear:YES];
	[self.view insertSubview:newViewController.view atIndex:0];
	[newViewController viewDidAppear:YES];
	//[UIView commitAnimations];
}

-(void)closePubMed {
	self.pubMedViewJustClosed = YES;
    self.pubMedViewJustOpened = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
