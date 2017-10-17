//
//  RootViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SearchResultsViewController.h"
#import "PrefsViewController.h"
#import "InfoViewController.h"
#import "SwitchViewController.h"
#import "PubMedViewController.h"
#import "NoResultsViewController.h"
#import "MiscMessageViewController.h"
#import "Prefs.h"
#import "Gene.h"
#import "constants.h"
#import "InterfaceUtil.h"
#import "UIDevice+Resolutions.h"

// class extension for private properties and methods
@interface RootViewController ()

@property BOOL hasSetupPrefs;
@property (retain, nonatomic) PrefsViewController *prefsViewController;
@property (retain, nonatomic) InfoViewController *infoViewController;
@property (retain, nonatomic) SearchViewController *searchViewController;
@property (retain, nonatomic) SearchResultsViewController *searchResultsViewController;
@property (retain, nonatomic) SwitchViewController *switchViewController;
@property (retain, nonatomic) NoResultsViewController *noResultsViewController;
@property (retain, nonatomic) MiscMessageViewController *miscMessageViewController;

-(void)setupPrefs;

@end

@implementation RootViewController

@synthesize hasSetupPrefs;
@synthesize query;
@synthesize searchViewController;
@synthesize searchResultsViewController;
@synthesize prefsViewController;
@synthesize infoViewController;
@synthesize switchViewController;
@synthesize noResultsViewController;
@synthesize miscMessageViewController;
@synthesize prefs;

-(void)setupPrefs {
	BOOL savePrefs = NO;
	self.prefs = [Prefs alloc];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.prefs.organism = [defaults objectForKey:kOrganismFilterKey];
	if (self.prefs.organism == nil) {
		savePrefs = YES;
		self.prefs.organism = [NSString stringWithFormat:kDefaultOrganism];
		[defaults setObject:self.prefs.organism forKey:kOrganismFilterKey];
	}
	self.prefs.rifsPerPage = [defaults objectForKey:kRIFsPerPageKey];
	if (self.prefs.rifsPerPage == nil) {
		self.prefs.rifsPerPage = [NSString stringWithFormat:kDefaultRIFsPerPage];
		[defaults setObject:self.prefs.rifsPerPage forKey:kRIFsPerPageKey];
	}
	self.prefs.enableAutorotation = ([[defaults objectForKey:kEnableAutorotationKey] isEqualToString:kAutorotationTrueValue]) ? YES : NO;
	if (savePrefs) {
		self.prefs.enableAutorotation = YES;
		[defaults setObject:kAutorotationTrueValue forKey:kEnableAutorotationKey];
	}
	self.prefs.retMax = [defaults objectForKey:kRetMaxKey];
	if (self.prefs.retMax == nil) {
		self.prefs.retMax = [NSString stringWithFormat:kDefaultRetMax];
		[defaults setObject:self.prefs.retMax forKey:kRetMaxKey];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidLoad {
    
    // setup our default view
    SearchViewController *searchController = ([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes) ?
    [[SearchViewController alloc] initWithNibName:@"TallerSearchView" bundle:nil] :
    [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:nil];

    //SearchViewController *searchController = [[SearchViewController alloc] initWithNibName:@"SearchView" bundle:nil];
	searchController.rootViewController = self;
	self.searchViewController = searchController;
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.view insertSubview:searchController.view atIndex:0];
	[searchController release];
	[super viewDidLoad];
    
    if (!self.hasSetupPrefs) {
		[self setupPrefs];
		self.hasSetupPrefs = YES;
	}
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    return ([InterfaceUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation prefs:self.prefs]);
}

- (void)dealloc {
	[self.query release];
	[self.prefs release];
	[self.switchViewController release];
	[self.prefsViewController release];
	[self.infoViewController release];
	[self.searchViewController release];
	[self.searchResultsViewController release];
	[self.noResultsViewController release];
	[self.miscMessageViewController release];
    [super dealloc];
}

-(void)searchComplete:(NSString *)searchResults {
	
	// results came from separate pool
	[searchResults autorelease];
	
	// searchResults is query:parserCode
	NSArray *components = [searchResults componentsSeparatedByString:kDelimiter];
	self.query = [components objectAtIndex:0];
	NSString *serverReturnCode = [components objectAtIndex:1];
	
	// get gene list - populate by parser
	NSMutableArray *genes = [(id)[[UIApplication sharedApplication] delegate] getGeneList];
		
	// based on search results, display different view
	if (![serverReturnCode isEqualToString:kSuccessCode] || [genes count] == 0) {
		[self displayNoRecordsFound:serverReturnCode];
	}
	else if ([genes count] == 1) {
		[self displaySwitchView:[genes objectAtIndex:0]];
	}
	else if ([genes count] > 1) {
		[self displaySearchResults];
	}
}

-(void)prefsView {
	
	if (self.prefsViewController == nil) {
		PrefsViewController *prefsController = [[PrefsViewController alloc] initWithNibName:@"PrefsView" bundle:nil];
		prefsController.rootViewController = self;
		self.prefsViewController = prefsController;
		[prefsController release];
	}
		
	if (self.prefsViewController.view.superview == nil) {
		[self.prefsViewController setupPrefVars];
		[self presentViewController:self.prefsViewController animated:YES completion:nil];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

-(void)infoView {
	
	if (self.infoViewController == nil) {
		InfoViewController *infoController = [[InfoViewController alloc] initWithNibName:@"InfoView" bundle:nil];
		infoController.rootViewController = self;
		self.infoViewController = infoController;
		[infoController release];
	}
	
	if (self.infoViewController.view.superview == nil) {
		self.infoViewController.request = [NSURLRequest requestWithURL:[NSURL URLWithString:kURLToReadme]];
		[self presentViewController:self.infoViewController animated:YES completion:nil];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

-(void)displayNoRecordsFound:(NSString *)serverReturnCode {
	if (self.noResultsViewController == nil) {
		NoResultsViewController *noResultsController = [[NoResultsViewController alloc] initWithNibName:@"NoResultsView" bundle:nil];
		self.noResultsViewController = noResultsController;
		[noResultsController release];
	}
	self.noResultsViewController.query = self.query;
	self.noResultsViewController.serverReturnCode = serverReturnCode;
	self.noResultsViewController.rootViewController = self;
	self.noResultsViewController.organism = self.prefs.organism;
	[self.navigationController pushViewController:self.noResultsViewController animated:YES];
}

-(void)displaySwitchView:(Gene *)gene {
	
	if (self.switchViewController == nil) {
		SwitchViewController *switchController = [[SwitchViewController alloc] initWithNibName:@"SwitchView" bundle:nil];
		switchController.rootViewController = self;
		self.switchViewController = switchController;
		[switchController release];
	}
	// set gene of interested on delegate
	[(id)[[UIApplication sharedApplication] delegate] setGeneOfInterest:gene];
	
	[self.navigationController pushViewController:self.switchViewController animated:YES];
}

-(void)displaySearchResults {
	
	if (self.searchResultsViewController == nil) {
		SearchResultsViewController *searchResultsController = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsView" bundle:nil];
		self.searchResultsViewController = searchResultsController;
		self.searchResultsViewController.rootViewController = self;
		[searchResultsController release];
	}
	[self.navigationController pushViewController:self.searchResultsViewController animated:YES];
}

-(void)displayMiscMessage:(NSString *)message {
	
	if (self.miscMessageViewController == nil) {
		MiscMessageViewController *miscMessageController = [[MiscMessageViewController alloc] initWithNibName:@"MiscMessageView" bundle:nil];
		self.miscMessageViewController = miscMessageController;
		self.miscMessageViewController.rootViewController = self;
		[miscMessageController release];
	}
	NSArray *components = [message componentsSeparatedByString:kDelimiter];
	self.miscMessageViewController.displayMessage = [components objectAtIndex:0];
	self.miscMessageViewController.displayTitle = [components objectAtIndex:1];
	
	[self.navigationController pushViewController:self.miscMessageViewController animated:YES];
}

-(void)parseErrorFromSearchResultsViewController:(NSString *)message {

	// pop search results view controller
	[self.navigationController popViewControllerAnimated:NO];
	[self displayMiscMessage:message];
}

@end

