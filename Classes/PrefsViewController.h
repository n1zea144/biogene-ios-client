//
//  PrefsViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;
@class PrefsPickerViewController;

@interface PrefsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	RootViewController *rootViewController;
	
@private
	UITableView *myTableView;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UIBarButtonItem *cancelButton;
	UISwitch *autorotationSwitchCtl;
	PrefsPickerViewController *prefsPickerViewController;
	NSArray *organismsFilterValues;
	NSArray *organismsFilterTitles;
	NSString *selectedOrganismFilter;
	NSInteger startOrganismFilterIndex;
	NSArray *numRIFsPerPage;
	NSString *selectedNumRIFsPerPage;
	NSInteger startNumRIFsPerPageIndex;
	NSArray *retMax;
	NSString *selectedRetMax;
	NSInteger retMaxIndex;
}

@property (nonatomic, retain) RootViewController *rootViewController;

-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
-(void)closePickerView:(PrefsPickerViewController *)pickerView;
-(void)setupPrefVars;

@end
