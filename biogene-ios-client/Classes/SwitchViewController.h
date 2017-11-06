//
//  SwitchViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;
@class SummaryViewController;
@class FunctionViewController;
@class RIFViewController;
@class PubMedViewController;

@interface SwitchViewController : UIViewController {

	RootViewController *rootViewController;
	
@private
	RIFViewController *rifViewController;
	PubMedViewController *pubMedViewController;
	SummaryViewController *summaryViewController;
	FunctionViewController *functionViewController;
	IBOutlet UISegmentedControl *uiSwitchViewSegmentedControl;
	IBOutlet UISegmentedControl *uiFontSizeSegmentedControl;
	BOOL pubMedViewJustClosed;
}

@property (retain, nonatomic) RootViewController *rootViewController;

-(IBAction)switchViewSegmentAction:(id)sender;
-(IBAction)fontSizeSegmentAction:(id)sender;
-(void)pubMedView:(id)sender url:(NSURL *)url;
-(void)closePubMed;

@end
