//
//  EntrezGeneSearchResultsController.m
//  biogene-client
//
//  Created by Benjamin on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "AppDelegate.h"
#import "SearchResultsCell.h"
#import "RootViewController.h"
#import "Prefs.h"
#import "constants.h"
#import "ProxyReader.h"
#import "ProxyUtil.h"
#import "InterfaceUtil.h"

#define PREVIOUS_SEGMENT_INDEX 0
#define NEXT_SEGMENT_INDEX 1

// class extension for private properties and methods
@interface SearchResultsViewController ()

@property NSInteger count;
@property NSInteger numResultsPerPage;
@property (retain, nonatomic) NSString *retstart;
@property (retain, nonatomic) NSString *prevRetstart;
@property (retain, nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet UILabel *paginationLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

-(void)setPaginationVars;
-(void)createSegmentedControl;
-(void)setSegmentButtons;
-(void)getEntrezGeneData;
-(void)setPaginationLabel;
-(void)restorePagination;

@end

@implementation SearchResultsViewController

@synthesize rootViewController;
@synthesize retstart;
@synthesize prevRetstart;
@synthesize numResultsPerPage;
@synthesize count;
@synthesize segmentedControl;
@synthesize activityView;
@synthesize paginationLabel;
@synthesize tableView;

#pragma mark UIViewController delegate methods

- (void)viewDidLoad {
	
	self.title = NSLocalizedString(kSearchResultsViewControllerTitle, @"SearchResultsViewController title");
	
	// setup pagination label
	self.paginationLabel.backgroundColor = [UIColor colorWithRed:0.94 green:0.96 blue:0.99 alpha:1.0];
	self.paginationLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.paginationLabel.textAlignment = NSTextAlignmentCenter;
	self.paginationLabel.textColor = [UIColor blackColor];
	
	// setup table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 48.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.sectionHeaderHeight = 0;
	
	// setup activity view
	CGRect activityViewRect = CGRectMake(kSearchResultsActivityViewX, kSearchResultsActivityViewY, kActivityViewWidth, kActivityViewHeight);
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:activityViewRect];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	self.activityView.hidden = YES;
	
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.autoresizesSubviews = YES;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.activityView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
										  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	
	// we want activity indicator at top
	[self.view insertSubview:self.activityView atIndex:2];
	
	// setup segment control
	[self createSegmentedControl];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	if (tableSelection != nil) {
		[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	}
	[self.tableView reloadData];
	
	[self setPaginationVars];
	[self setSegmentButtons];
	[self setPaginationLabel];
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
	[self.retstart release];
	[self.prevRetstart release];
	[self.segmentedControl release];
	[self.rootViewController release];
	[self.activityView release];
	[self.paginationLabel release];
	[self.tableView release];
    [super dealloc];
}

-(void)setPaginationVars {
	
	// set restart - used in url to webservice
	self.retstart = [(id)[[UIApplication sharedApplication] delegate] getRetstart];
	
	// get total number of resultscount
	NSString *countStr = [(id)[[UIApplication sharedApplication] delegate] getCount];
	self.count = [countStr integerValue];
	
	// get number results per page
	self.numResultsPerPage = self.rootViewController.prefs.retMaxInteger;
}

-(void)setPaginationLabel {

	// get record start (add one since we start from zero)
	NSInteger retStartInt = [self.retstart integerValue];
	NSString *retStart = [NSString stringWithFormat:@"%i", retStartInt + 1];

	// number of records in table - the number we are display
	NSString *numberOfRows = [NSString stringWithFormat:@"%i", retStartInt + [self.tableView numberOfRowsInSection:0]];
	
	// total records
	NSString *countStr = [(id)[[UIApplication sharedApplication] delegate] getCount];
	
	// set label
	self.paginationLabel.text = [InterfaceUtil getPaginationString:YES start:retStart end:numberOfRows total:countStr];
}

-(void)restorePagination {
	self.retstart = self.prevRetstart;
	[self setSegmentButtons];
}

#pragma mark UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[(id)[[UIApplication sharedApplication] delegate] getGeneList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *MyIdentifier = @"MyIdentifier";
    
  	SearchResultsCell *cell = (SearchResultsCell *)[self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
        cell = [[[SearchResultsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	// setup the cell
	Gene *geneForRow = [(id)[[UIApplication sharedApplication] delegate] geneInListAtIndex:indexPath.row];
    [cell setGene:geneForRow];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[self.rootViewController displaySwitchView:[(SearchResultsCell *)[self.tableView cellForRowAtIndexPath:indexPath] gene]];
}

- (void)createSegmentedControl {
	
	// setup segment control
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:
							 [NSArray arrayWithObjects:
							 [UIImage imageNamed:@"up.png"],
							 [UIImage imageNamed:@"down.png"],
							  nil]];
	[self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	self.segmentedControl.frame = CGRectMake(0, 0, 90, 30);
	self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	self.segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl] autorelease];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
}

- (void)segmentAction:(id)sender {
	
	// check reachability
	BOOL networkReachable = [ProxyUtil networkReachable];
	if (!networkReachable) {
		[ProxyUtil showAlertNetworkUnreachable];
		return;
	}
	
	NSInteger selectedIndex = [self.segmentedControl selectedSegmentIndex];
	NSInteger retstartInt = [self.retstart integerValue];
	
	if (selectedIndex == PREVIOUS_SEGMENT_INDEX) {
		retstartInt -= self.numResultsPerPage;
		if (retstartInt < 0) {
			retstartInt = 0;
		}
	}
	else {
		retstartInt += self.numResultsPerPage;
		if (retstartInt >= self.count) {
			retstartInt -= self.numResultsPerPage;
		}
	}
	self.prevRetstart = self.retstart;
	self.retstart = [NSString stringWithFormat:@"%d", retstartInt];
	
	[self setSegmentButtons];
	
	// this is where we fetch
	// spawn a thread to fetch the entrez gene data so that the UI is not blocked while the application parses the XML file.
    [NSThread detachNewThreadSelector:@selector(getEntrezGeneData) toTarget:self withObject:nil];
	
	// start some animations - they will be stopped in getEntrezGene
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.activityView.hidden = NO;
	[self.activityView startAnimating];
	
}

- (void)setSegmentButtons {
	
	NSInteger retstartInt = [self.retstart integerValue];
	
	// set buttons appropriately
	BOOL enablePrevButton = !(retstartInt == 0);
	[self.segmentedControl setEnabled:enablePrevButton forSegmentAtIndex:PREVIOUS_SEGMENT_INDEX];
	BOOL enableNextButton = (retstartInt + self.numResultsPerPage < self.count-1);
	[self.segmentedControl setEnabled:enableNextButton forSegmentAtIndex:NEXT_SEGMENT_INDEX];
}

-(void)getEntrezGeneData {
	
	// this runs in its own thread, setup pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// clear out any previous search results
	[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(clearGeneList) withObject:nil waitUntilDone:YES];
	
	// create search url
	NSString *proxyURL = [ProxyUtil createSearchURL:self.rootViewController.query organism:self.rootViewController.prefs.organism retstart:self.retstart retmax:self.rootViewController.prefs.retMaxAbbr];

	// perform fetch
	NSError *parseError = nil;
	NSString *serverReturnCode = nil;
    ProxyReader *proxyReader = [[ProxyReader alloc] init];
	[proxyReader parseXMLFileAtURL:[NSURL URLWithString:proxyURL] parseError:&parseError serverReturnCode:&serverReturnCode];
	
	// end animations
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityView stopAnimating];
	self.activityView.hidden = YES;
	
	// notify root view controller that search is complete
	if (parseError != nil) {
		// houston we have a problem
		[ProxyUtil performSelectorOnMainThread:@selector(showAlertUnexpectedError) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(restorePagination) withObject:nil waitUntilDone:NO];
	}
	else {
		// update delegate with ret start
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(setRetstart:) withObject:self.retstart waitUntilDone:YES];
		// reload this view controller
		[self performSelectorOnMainThread:@selector(viewWillAppear:) withObject:NO waitUntilDone:NO];
	}
	
	// release resources
	[proxyReader release];
	[pool release];
}

@end

