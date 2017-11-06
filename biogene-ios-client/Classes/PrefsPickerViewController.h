//
//  PrefsPickerViewController.h
//  biogene-client
//
//  Created by Benjamin on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PrefsViewController;
@class RootViewController;

@interface PrefsPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	
	PrefsViewController *prefsViewController;
	NSArray *items;
	NSString *selectedItem;
	NSInteger startItemIndex;
	NSString *viewTitle;
	RootViewController *rootViewController;
	
@private
	IBOutlet UILabel *titleLabel;
	IBOutlet UIPickerView *picker;
}

@property NSInteger startItemIndex;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSString *selectedItem;
@property (nonatomic, retain) NSString *viewTitle;
@property (nonatomic, retain) PrefsViewController *prefsViewController;
@property (retain, nonatomic) RootViewController *rootViewController;

-(IBAction)close:(id)sender;
-(IBAction)itemSelected;

@end
