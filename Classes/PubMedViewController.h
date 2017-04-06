//
//  PubMedViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class SwitchViewController;

@interface PubMedViewController : UIViewController <UIWebViewDelegate> {

	NSURL *url;
	RootViewController *rootViewController;
	SwitchViewController *switchViewController;
	NSInteger fontSize;
	NSInteger headerFontSize;
	
@private
	IBOutlet UIWebView *uiWebView;
	IBOutlet UIBarButtonItem *closeButton;
	IBOutlet UIBarButtonItem *pubMedButton;
	IBOutlet UILabel *titleLabel;
	IBOutlet UISegmentedControl *uiFontSizeSegmentedControl;
	UIActivityIndicatorView *activityView;
	NSString *abstractPlus;
}

@property (retain, nonatomic) NSURL *url;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) SwitchViewController *switchViewController;
@property NSInteger fontSize;
@property NSInteger headerFontSize;

-(BOOL)fontSizeIncrease:(BOOL)redraw;
-(BOOL)fontSizeDecrease:(BOOL)redraw;

-(IBAction)close:(id)sender;
-(IBAction)gotoPubMed:(id)sender;
-(IBAction)fontSizeSegmentAction:(id)sender;

@end
