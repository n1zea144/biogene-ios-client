//
//  NoResultsViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface NoResultsViewController : UIViewController {

	NSString *query;
	NSString *organism;
	NSString *serverReturnCode;
	RootViewController *rootViewController;
@private
	IBOutlet UIWebView *uiWebView;
}

@property (nonatomic, retain) NSString* query;
@property (nonatomic, retain) NSString* organism;
@property (nonatomic, retain) NSString* serverReturnCode;
@property (retain, nonatomic) RootViewController *rootViewController;

@end
