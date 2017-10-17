//
//  RootViewController.h
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Prefs;
@class PrefsViewController;
@class InfoViewController;
@class SearchViewController;
@class SearchResultsViewController;
@class SwitchViewController;
@class NoResultsViewController;
@class MiscMessageViewController;
@class Gene;

@interface RootViewController : UIViewController {
	
	Prefs *prefs;
	NSString *query;
	
@private
	BOOL hasSetupPrefs;
 	PrefsViewController *prefsViewController;
	InfoViewController *infoViewController;
	SearchViewController *searchViewController;
	SearchResultsViewController *searchResultsViewController;
	SwitchViewController *switchViewController;
	NoResultsViewController *noResultsViewController;
	MiscMessageViewController *miscMessageViewController;
}

-(void)prefsView;
-(void)infoView;
-(void)displaySearchResults;
-(void)displaySwitchView:(Gene *)gene;
-(void)displayMiscMessage:(NSString *)message;
-(void)searchComplete:(NSString *)searchResults;
-(void)displayNoRecordsFound:(NSString *)parserCode;
-(void)parseErrorFromSearchResultsViewController:(NSString *)message;

@property (retain, nonatomic) Prefs *prefs;
@property (retain, nonatomic) NSString *query;

@end
