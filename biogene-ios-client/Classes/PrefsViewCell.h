//
//  PrefsViewCell.h
//  biogene-client
//
//  Created by Benjamin on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrefsViewCell : UITableViewCell {

	UILabel	*nameLabel;
	UILabel *valueLabel;
	UIView	*view;
}

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *valueLabel;

- (void)setView:(UIView *)inView;


@end
