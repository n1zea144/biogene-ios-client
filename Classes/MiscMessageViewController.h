//
//  MiscMessageViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface MiscMessageViewController : UIViewController {

	NSString *displayTitle;
	NSString *displayMessage;
	RootViewController *rootViewController;
	
@private
	IBOutlet UIWebView *uiWebView;
}

@property (nonatomic, retain) NSString* displayTitle;
@property (nonatomic, retain) NSString* displayMessage;
@property (retain, nonatomic) RootViewController *rootViewController;

@end
