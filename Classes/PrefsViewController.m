//
//  PrefsViewController.m
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefsViewController.h"
#import "PrefsPickerViewController.h"
#import "RootViewController.h"
#import "PrefsViewCell.h"
#import "Prefs.h"
#import "constants.h"
#import "InterfaceUtil.h"

// class extension for private properties and methods
@interface PrefsViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UISwitch *autorotationSwitchCtl;
@property (nonatomic, retain) PrefsPickerViewController *prefsPickerViewController;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSArray *organismsFilterValues;
@property (nonatomic, retain) NSArray *organismsFilterTitles;
@property (nonatomic, retain) NSString *selectedOrganismFilter;
@property NSInteger startOrganismFilterIndex;
@property (nonatomic, retain) NSArray *numRIFsPerPage;
@property (nonatomic, retain) NSString *selectedNumRIFsPerPage;
@property NSInteger startNumRIFsPerPageIndex;
@property (nonatomic, retain) NSArray *retMax;
@property (nonatomic, retain) NSString *selectedRetMax;
@property NSInteger retMaxIndex;

-(void)pickerButtonTapped:(NSIndexPath *)indexPath;
- (NSString*) getTitleFromValueOrReverse:(NSArray*)fromItems toItems:(NSArray*)toItems selectedItem:(NSString*)selectedItem;
-(NSInteger)getPrefsIndex:(NSArray*)items selectedItem:(NSString*)item;

@end

@implementation PrefsViewController

@synthesize titleLabel;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize autorotationSwitchCtl;
@synthesize myTableView;
@synthesize rootViewController;
@synthesize prefsPickerViewController;
@synthesize organismsFilterValues;
@synthesize organismsFilterTitles;
@synthesize selectedOrganismFilter;
@synthesize startOrganismFilterIndex;
@synthesize numRIFsPerPage;
@synthesize selectedNumRIFsPerPage;
@synthesize startNumRIFsPerPageIndex;
@synthesize retMax;
@synthesize selectedRetMax;
@synthesize retMaxIndex;

enum TableSections {
	kFilterSection = 0,
	kViewingSection
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidLoad {
	
	// setup autorotation switch
	CGRect switchFrame = CGRectMake(0.0, 0.0, kAutorotationSwitchWidth, kAutorotationSwitchHeight);
	self.autorotationSwitchCtl = [[UISwitch alloc] initWithFrame:switchFrame];
	//[self.autorotationSwitchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
	// in case the parent view draws with a custom color or gradient, use a transparent color
	self.autorotationSwitchCtl.backgroundColor = [UIColor clearColor];
	
	// setup label
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
	self.titleLabel.text = NSLocalizedString(kPrefsViewControllerTitle, @"PrefsViewController title");

	// create and configure the table view
	CGRect frame = CGRectMake(0.0, 44.0, 320, 416);
	self.myTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];	
	self.myTableView.delegate = self;
	self.myTableView.dataSource = self;
	self.myTableView.autoresizesSubviews = YES;
	[self.view insertSubview:self.myTableView atIndex:0];
	
	// following lines required to properly handle rotation
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.myTableView.autoresizesSubviews = YES;
	self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[super viewDidLoad];
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    return ([InterfaceUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation prefs:self.rootViewController.prefs]);
}

- (void)dealloc {
	
	[self.titleLabel release];
	[self.cancelButton release];
	[self.saveButton release];
	[self.autorotationSwitchCtl release];
	[self.myTableView release];
	[self.rootViewController release];
	if (self.prefsPickerViewController != nil) {
		[self.prefsPickerViewController release];
	}
	[self.organismsFilterValues release];
	[self.organismsFilterTitles release];
	[self.selectedOrganismFilter release];
	[self.numRIFsPerPage release];
	[self.selectedNumRIFsPerPage release];
	[self.retMax release];
	[self.selectedRetMax release];
    [super dealloc];
}

//
// setup pref vars on startup
//
-(void)setupPrefVars {
	
	// setup some wars used below
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *bPath = [[NSBundle mainBundle] bundlePath];
	NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];	
	NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
	NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
	
	// read default organism filter from user defaults
	self.selectedOrganismFilter = [defaults objectForKey:kOrganismFilterKey];
	
	// populate array of all possible organism filter values
	NSDictionary *organismPreferences = [preferencesArray objectAtIndex:ORGANISM_FILTER_INDEX];
	self.organismsFilterTitles = [organismPreferences objectForKey:@"Titles"];
	self.organismsFilterValues = [organismPreferences objectForKey:@"Values"];
	
	// set organism start index
	self.startOrganismFilterIndex = [self getPrefsIndex:self.organismsFilterValues selectedItem:self.selectedOrganismFilter];
	
	// read default num rifs per page
	self.selectedNumRIFsPerPage = [defaults objectForKey:kRIFsPerPageKey];
	
	// populate num rifs array
	NSDictionary *numRIFsPerPagePreferences = [preferencesArray objectAtIndex:RIFS_PER_PAGE_INDEX];
	self.numRIFsPerPage = [numRIFsPerPagePreferences objectForKey:@"Titles"];
	
	// setup num rifs start index
	self.startNumRIFsPerPageIndex = [self getPrefsIndex:self.numRIFsPerPage selectedItem:self.selectedNumRIFsPerPage];
	
	// set autorotation switch
	self.autorotationSwitchCtl.on = ([[defaults objectForKey:kEnableAutorotationKey] isEqualToString:kAutorotationTrueValue]) ? YES : NO;
	
	// read default ret max
	self.selectedRetMax = [defaults objectForKey:kRetMaxKey];
	
	// populate ret max array
	NSDictionary *retMaxPreferences = [preferencesArray objectAtIndex:RET_MAX_INDEX];
	self.retMax = [retMaxPreferences objectForKey:@"Titles"];
	
	// set ret max start index
	self.retMaxIndex = [self getPrefsIndex:self.retMax selectedItem:self.selectedRetMax];
}

//
// goes from value to title or reverse
//
- (NSString*) getTitleFromValueOrReverse:(NSArray*)fromItems toItems:(NSArray*)toItems selectedItem:(NSString*)selectedItem {
	
	for(int lc = 0; lc < [fromItems count]; lc++) {
		NSString *currentFromItem = [fromItems objectAtIndex:lc];
		if ([currentFromItem isEqualToString:selectedItem]) {
			return [toItems objectAtIndex:lc];
		}
	}
	
	// made it here
	return nil;
}

//
// given an array of items return the index based on item
//
- (NSInteger)getPrefsIndex:(NSArray*)items selectedItem:(NSString*)item {
	
	// setup num rifs start index
	for (int lc = 0; lc < [items count]; lc++) {
		NSString *currentItem = [items objectAtIndex:lc];
		if ([currentItem isEqualToString:item]) {
			return lc;
		}
	}

	// made it here
	return 0;
}

//
// cancel button action
//
-(IBAction)cancel:(id)sender {
	[self.rootViewController prefsView];
}

//
// save button action
//
-(IBAction)save:(id)sender {
	
	// set properties on prefs object
	self.rootViewController.prefs.organism = self.selectedOrganismFilter;
	self.rootViewController.prefs.rifsPerPage = self.selectedNumRIFsPerPage;
	self.rootViewController.prefs.enableAutorotation = self.autorotationSwitchCtl.on;
	self.rootViewController.prefs.retMax = self.selectedRetMax;
	
	// set prefs in user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.selectedOrganismFilter forKey:kOrganismFilterKey];
	[defaults setObject:self.selectedNumRIFsPerPage forKey:kRIFsPerPageKey];
	NSString *enableAutorotation = [NSString stringWithFormat:(self.autorotationSwitchCtl.on) ? kAutorotationTrueValue : kAutorotationFalseValue];
	[defaults setObject:enableAutorotation forKey:kEnableAutorotationKey];
	[defaults setObject:self.selectedRetMax forKey:kRetMaxKey];
	
	[self.rootViewController prefsView];
}

#
#pragma mark UIViewController delegate methods
#
- (void)viewWillAppear:(BOOL)animated {
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.myTableView indexPathForSelectedRow];
	[self.myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	[self.myTableView reloadData];
}

#
#pragma mark - UITableViewDataSource delegate
#
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == kViewingSection) ? 3 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *title;
	switch (section) {
		case kFilterSection:
		{
			title = kFiltersSectionTitle;
			break;
		}
		case kViewingSection:
		{
			title = kViewingSectionTitle;
			break;
		}
	}
	return title;
}

#
#pragma mark UITableViewDelegate
#

// decide what kind of accesory view (to the far right) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	BOOL slider = (indexPath.section == kViewingSection && ([indexPath row] == 2));
	return (slider) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
}

//
// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kRowHeight;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger row = [indexPath row];
	static NSString *MyIdentifier = @"MyIdentifier";
	
	PrefsViewCell *cell = (PrefsViewCell *)[self.myTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
        cell = [[[PrefsViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
	}
	
	switch (indexPath.section) {
		case kFilterSection:
		{
			// organism filter
			if (row == 0) {
				cell.textLabel.text = kOrganismFilterTitle;
				cell.detailTextLabel.text = [self getTitleFromValueOrReverse:self.organismsFilterValues toItems:self.organismsFilterTitles selectedItem:self.selectedOrganismFilter];
			}
			break;
		}
		case kViewingSection:
		{
			// show rifs per page
			if (row == 0) {
				cell.textLabel.text = kRetMaxTitle;
				cell.detailTextLabel.text = self.selectedRetMax;
			}
			else if (row == 1) {
				cell.textLabel.text = kShowRIFsPerPageTitle;
				cell.detailTextLabel.text = self.selectedNumRIFsPerPage;
			}
			// enable autorotation slider
			else {
				cell.textLabel.text = kEnableAutorotationTitle;
				cell.view = self.autorotationSwitchCtl;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		}
	}
	
	// outta here
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	if (!(indexPath.section == kViewingSection && row == 2)) {
		[self pickerButtonTapped:indexPath];
	}
}

//
// method called when picker pref is selected
//
-(void)pickerButtonTapped:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	
	// create picker view in necessary
	if (self.prefsPickerViewController == nil) {
		PrefsPickerViewController *prefsPicker = [[PrefsPickerViewController alloc] initWithNibName:@"PrefsPickerView" bundle:nil];
		prefsPicker.prefsViewController = self;
		prefsPicker.rootViewController = self.rootViewController;
		self.prefsPickerViewController = prefsPicker;
		self.prefsPickerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[prefsPicker release];
	}
	
	// based on sender, set appropriate properties
	if (indexPath.section == kFilterSection && row == 0) {
		self.prefsPickerViewController.startItemIndex = self.startOrganismFilterIndex;
		self.prefsPickerViewController.items = self.organismsFilterTitles;
		self.prefsPickerViewController.selectedItem = [self getTitleFromValueOrReverse:self.organismsFilterValues toItems:self.organismsFilterTitles selectedItem:self.selectedOrganismFilter];
		self.prefsPickerViewController.viewTitle = kOrganismFilterTitle;
	}
	else if (indexPath.section == kViewingSection && row == 0) {
		self.prefsPickerViewController.startItemIndex = self.retMaxIndex;
		self.prefsPickerViewController.items = self.retMax;
		self.prefsPickerViewController.selectedItem = self.selectedRetMax;
		self.prefsPickerViewController.viewTitle = kRetMaxTitle;
	}
	else if (indexPath.section == kViewingSection && row == 1) {
		self.prefsPickerViewController.startItemIndex = self.startNumRIFsPerPageIndex;
		self.prefsPickerViewController.items = self.numRIFsPerPage;
		self.prefsPickerViewController.selectedItem = self.selectedNumRIFsPerPage;
		self.prefsPickerViewController.viewTitle = kShowRIFsPerPageTitle;
	}
	
	// render the dialog
	[self presentViewController:self.prefsPickerViewController animated:YES completion:nil];
}

//
// method called by PrefsPickerViewController to close dialog
//
-(void)closePickerView:(PrefsPickerViewController *)pickerView {
	
	// set prefs based on picker ref
	NSArray * items = pickerView.items;
	if (items == self.organismsFilterTitles) {
		// we are dealing with organism picker
		self.selectedOrganismFilter = [self getTitleFromValueOrReverse:self.organismsFilterTitles toItems:self.organismsFilterValues selectedItem:pickerView.selectedItem];
		self.startOrganismFilterIndex = [self getPrefsIndex:self.organismsFilterValues selectedItem:self.selectedOrganismFilter];
	}
	else if (items == self.numRIFsPerPage) {
		// we are dealing with rifs picker
		self.selectedNumRIFsPerPage = pickerView.selectedItem;
		self.startNumRIFsPerPageIndex = [self getPrefsIndex:self.numRIFsPerPage selectedItem:self.selectedNumRIFsPerPage];
	}
	else if (items == self.retMax) {
		// we are dealing with ret max picker
		self.selectedRetMax = pickerView.selectedItem;
		self.retMaxIndex = [self getPrefsIndex:self.retMax selectedItem:self.selectedRetMax];
	}
	
	// now close picker
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
