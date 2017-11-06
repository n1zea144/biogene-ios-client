//
//  PrefsViewCell.m
//  biogene-client
//
//  Created by Benjamin on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefsViewCell.h"
#import "constants.h"

// class extension for private properties and methods
@interface PrefsViewCell()

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end

@implementation PrefsViewCell

@synthesize view;
@synthesize nameLabel;
@synthesize valueLabel;

- (void)dealloc {
	[self.view release];
	[self.nameLabel release];
	[self.valueLabel release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)aRect reuseIdentifier:(NSString *)identifier {

	if (self = [super initWithFrame:aRect reuseIdentifier:identifier]) {
		
		UIView *myContentView = self.contentView;
		
		self.nameLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:18.0 bold:YES];
		[myContentView addSubview:self.nameLabel];
		
		self.valueLabel = [self newLabelWithPrimaryColor:[UIColor colorWithRed:0.20 green:0.31 blue:0.52 alpha:1.0] selectedColor:[UIColor whiteColor] fontSize:16.0 bold:NO];
		[myContentView addSubview:self.valueLabel];
	}
	return self;
}

- (void)setView:(UIView *)inView
{
	if (view)
		[view removeFromSuperview];
	view = inView;
	[self.view retain];
	[self.contentView addSubview:inView];
	
	[self layoutSubviews];
	
	// we do not want switch view color to change on selection
	if ([self.view isKindOfClass:[UISwitch class]]) {
		self.nameLabel.highlightedTextColor = [UIColor blackColor];
	}
}

- (void)layoutSubviews {	

	[super layoutSubviews];
    CGRect cellRect = [self.contentView bounds];
	
	// in this example we will never be editing, but this illustrates the appropriate pattern
	if (!self.editing) {
		
		// determine bounds for labels
		CGSize size;
		CGRect frame;
		
		// determine bounds for name label
		size = [self.nameLabel.text sizeWithFont:self.nameLabel.font];
		
        // place the name label
		frame = CGRectMake(cellRect.origin.x + kCellLeftOffset, kCellTopOffset, size.width, kCellHeight);
		self.nameLabel.frame = frame;
		
		if ([self.view isKindOfClass:[UISwitch class]]) {
			NSInteger originX = (cellRect.origin.x + cellRect.size.width) - kAutorotationSwitchWidth - kCellLeftOffset;
			frame = CGRectMake(originX, kCellTopOffset, kAutorotationSwitchWidth, kCellHeight);
			self.view.frame = frame;
		}
		else {
			// determine bounds for value label - compute offset from right hand side - 
			// we subtract additional kCellLeftOffset to give space between text and disclosure
			size = [self.valueLabel.text sizeWithFont:self.valueLabel.font];
			NSInteger originX = (cellRect.origin.x + cellRect.size.width) - size.width - kCellLeftOffset;
        
			// place the formatted name label
			frame = CGRectMake(originX, kCellTopOffset, size.width, kCellHeight);
			self.valueLabel.frame = frame;
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	// Views are drawn most efficiently when they are opaque and do not have a clear background,
	//so in newLabelForMainText: the labels are made opaque and given a white background.
	// To show selection properly, however,
	// the views need to be transparent (so that the selection color shows through).  
	[super setSelected:selected animated:animated];
	
	UIColor *backgroundColor = nil;
	if (selected) {
		backgroundColor = [UIColor clearColor];
	}
	else {
		backgroundColor = [UIColor whiteColor];
	}
    
	self.nameLabel.backgroundColor = backgroundColor;
	self.nameLabel.highlighted = selected;
	self.nameLabel.opaque = !selected;
	
	self.valueLabel.backgroundColor = backgroundColor;
	self.valueLabel.highlighted = selected;
	self.valueLabel.opaque = !selected;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold {
	
	// create and configure a label
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
	// Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.
	// To show selection properly, however, the views need to be transparent (so that the selection color shows through).
	// This is handled in setSelected:animated:.
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	// outta here
	return newLabel;
}

@end
