//
//  InfoViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface InfoViewController : UIViewController <UIWebViewDelegate> {

	NSURLRequest *request;
	RootViewController *rootViewController;
	IBOutlet UILabel *titleLabel;
	
@private
	IBOutlet UIWebView *uiWebView;
	UIActivityIndicatorView *activityView;
}

@property (retain, nonatomic) NSURLRequest *request;
@property (nonatomic, retain) RootViewController *rootViewController;

-(IBAction)close:(id)sender;

@end
