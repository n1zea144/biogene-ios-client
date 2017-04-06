//
//  SummaryViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryViewController : UIViewController <UIWebViewDelegate> {

	NSInteger valueFontSize;
	NSInteger headerFontSize;
@private
	IBOutlet UIWebView *uiWebView;
}

@property NSInteger valueFontSize;
@property NSInteger headerFontSize;

-(void)clearScreen;
-(BOOL)fontSizeIncrease:(BOOL)redraw;
-(BOOL)fontSizeDecrease:(BOOL)redraw;

@end
