//
//  PrefsPickerViewController.m
//  biogene-client
//
//  Created by Benjamin on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefsPickerViewController.h"
#import "PrefsViewController.h"
#import "Prefs.h"
#import "InterfaceUtil.h"
#import "RootViewController.h"

// class extension for private properties and methods
@interface PrefsPickerViewController ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *picker;

@end

@implementation PrefsPickerViewController

@synthesize items;
@synthesize picker;
@synthesize titleLabel;
@synthesize selectedItem;
@synthesize startItemIndex;
@synthesize viewTitle;
@synthesize prefsViewController;
@synthesize rootViewController;

- (void)viewWillAppear:(BOOL)animated {
	[self.picker reloadComponent:0];
	[self.picker selectRow:self.startItemIndex inComponent:0 animated:NO];
	self.titleLabel.text = self.viewTitle;
}

-(void)viewDidLoad {
	
	// setup label
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
	self.titleLabel.text = self.viewTitle;
	[self.picker selectRow:self.startItemIndex inComponent:0 animated:NO];
	[super viewDidLoad];
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
	[self.items release];
	[self.picker release];
	[self.selectedItem release];
	[self.prefsViewController release];
	[self.rootViewController release];
	[self.titleLabel release];
	[self.viewTitle release];
    [super dealloc];
}

// save button action
-(IBAction)close:(id)sender {
	// outta here
	[self.prefsViewController closePickerView:self];
}

-(IBAction)itemSelected {
	NSInteger row = [self.picker selectedRowInComponent:0];
	self.selectedItem = [self.items objectAtIndex:row];
}

#pragma mark picker data source methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.items count];
}

#pragma mark picker delegate methods
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.items objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.selectedItem = [self.items objectAtIndex:row];
}

@end
