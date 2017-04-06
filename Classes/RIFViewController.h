//
//  RIFViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchViewController;

@interface RIFViewController : UIViewController <UIWebViewDelegate> {

	SwitchViewController *switchViewController;
	NSInteger fontSize;
	IBOutlet UILabel *paginationLabel;
	BOOL resetPagination;
	
@private
	IBOutlet UIWebView *uiWebView;
	NSInteger currentRIFPage;
	NSInteger maxRIFPage;
	UISegmentedControl *segmentedControl;
}

@property NSInteger fontSize;
@property BOOL resetPagination;
@property (nonatomic, retain) SwitchViewController *switchViewController;

-(BOOL)fontSizeIncrease:(BOOL)redraw;
-(BOOL)fontSizeDecrease:(BOOL)redraw;

@end
