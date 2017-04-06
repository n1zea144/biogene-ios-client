//
//  FunctionViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionViewController : UIViewController {

	NSInteger fontSize;
@private
	IBOutlet UIWebView *uiWebView;
}

@property NSInteger fontSize;

-(BOOL)fontSizeIncrease:(BOOL)redraw;
-(BOOL)fontSizeDecrease:(BOOL)redraw;

@end
