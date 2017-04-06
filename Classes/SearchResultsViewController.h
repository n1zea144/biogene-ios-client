//
//  EntrezGeneSearchResultsController.h
//  biogene-client
//
//  Created by Benjamin on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface SearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	RootViewController *rootViewController;
	IBOutlet UILabel *paginationLabel;
	IBOutlet UITableView *tableView;
	
@private
	NSInteger count;
	NSInteger numResultsPerPage;
	NSString *prevRetstart;
	NSString *retstart;
	UISegmentedControl *segmentedControl;
	UIActivityIndicatorView *activityView;
}

@property (retain, nonatomic) RootViewController *rootViewController;

@end
