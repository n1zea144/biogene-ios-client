//
//  SearchViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate> {
	
	RootViewController *rootViewController;
	
@private
	IBOutlet UISearchBar *search;
	IBOutlet UIButton *prefsButton;
	IBOutlet UIButton *infoButton;
	UIActivityIndicatorView *activityView;
	IBOutlet UIWebView *uiWebView;
}

@property (nonatomic, retain) RootViewController *rootViewController;

-(IBAction)prefsView:(id)sender;
-(IBAction)infoView:(id)sender;

@end
