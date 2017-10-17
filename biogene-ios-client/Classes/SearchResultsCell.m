#import "SearchResultsCell.h"
#import "Gene.h"
#import "constants.h"
#import "InterfaceUtil.h"

// class extension for private properties and methods
@interface SearchResultsCell()

@property (nonatomic, retain) UILabel *symbolLabel;
@property (nonatomic, retain) UILabel *organismLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end

@implementation SearchResultsCell

@synthesize symbolLabel;
@synthesize organismLabel;
@synthesize descriptionLabel;

- (void)dealloc {
	[self.symbolLabel release];
	[self.organismLabel release];
	[self.descriptionLabel release];
	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *myContentView = self.contentView;
        
        // gene symbol label
        self.symbolLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:18.0 bold:YES];
		self.symbolLabel.textAlignment = NSTextAlignmentLeft; // default
		[myContentView addSubview:self.symbolLabel];
		
		// gene organism label
		self.organismLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:14.0 bold:NO];
		self.organismLabel.textAlignment = NSTextAlignmentLeft; // default
		[myContentView addSubview:self.organismLabel];
        
        // gene description label
		self.descriptionLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:14.0 bold:NO];
		self.descriptionLabel.textAlignment = NSTextAlignmentLeft; // default
		[myContentView addSubview:self.descriptionLabel];
    }
    return self;
}

- (Gene *)gene {
    return gene;
}

// Rather than using one of the standard UITableViewCell content properties like 'text',
// we're using a custom property called 'entrezGene' to populate the table cell. Whenever the
// value of that property changes, we need to call [self setNeedsDisplay] to force the
// cell to be redrawn.
- (void)setGene:(Gene *)newGene {
	
	// set gene reference
	[newGene retain];
	[gene release];
	gene = newGene;

	// set label text - gene symbol
	self.symbolLabel.text = [InterfaceUtil getGeneSymbol:newGene];
	if (self.symbolLabel.text == nil) {
		self.symbolLabel.text = kNoSymbol;
	}
	
	// set label text - organism label
	if (newGene.organism != nil && [newGene.organism length] > 0) {
		self.organismLabel.text = [NSString stringWithFormat:@"(%@)", newGene.organism];
	}
	
	// set label text - description label
	self.descriptionLabel.text = (newGene.description != nil && [newGene.description length] > 0) ?
		newGene.description : kNoDescription;
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    
#define LEFT_COLUMN_OFFSET 10
#define RIGHT_COLUMN_OFFSET 10
	
#define UPPER_ROW_TOP 4
#define UPPER_ROW_HEIGHT 20
#define UPPER_ROW_SPACER 5
#define LOWER_ROW_TOP 28
#define LOWER_ROW_HEIGHT 16
    
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
		CGRect frame;
        CGFloat boundsX = contentRect.origin.x;
		CGFloat spaceRemaining = contentRect.size.width - LEFT_COLUMN_OFFSET - RIGHT_COLUMN_OFFSET;
		
		// determine some sizes
		CGSize symbolSize = [self.symbolLabel.text sizeWithFont:self.symbolLabel.font];
		symbolSize.width = (symbolSize.width > spaceRemaining) ? spaceRemaining : symbolSize.width;
        
        // place symbol label
		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET,
						   UPPER_ROW_TOP,
							symbolSize.width,
						   UPPER_ROW_HEIGHT);
		self.symbolLabel.frame = frame;
		
		// update space remaining
		spaceRemaining -= (symbolSize.width + UPPER_ROW_SPACER);
		
		// place organism label after layout out symbol
		if (self.organismLabel.text != nil && [self.organismLabel.text length] > 0) {
			CGSize organismSize = [self.organismLabel.text sizeWithFont:self.organismLabel.font];
			organismSize.width = (organismSize.width > spaceRemaining) ? spaceRemaining : organismSize.width;
			frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET + symbolSize.width + UPPER_ROW_SPACER,
							   UPPER_ROW_TOP, 
							   (spaceRemaining > 0) ? organismSize.width : 0,
							   UPPER_ROW_HEIGHT);
			self.organismLabel.frame = frame;
		}
        
        // place the description label (right margin of left_column_offset)
		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET,
						   LOWER_ROW_TOP,
						   contentRect.size.width - (boundsX + LEFT_COLUMN_OFFSET + LEFT_COLUMN_OFFSET),
						   LOWER_ROW_HEIGHT);
		self.descriptionLabel.frame = frame;
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
	} else {
		backgroundColor = [UIColor whiteColor];
	}
    
	self.symbolLabel.backgroundColor = backgroundColor;
	self.symbolLabel.highlighted = selected;
	self.symbolLabel.opaque = !selected;
	
	self.organismLabel.backgroundColor = backgroundColor;
	self.organismLabel.highlighted = selected;
	self.organismLabel.opaque = !selected;

	self.descriptionLabel.backgroundColor = backgroundColor;
	self.descriptionLabel.highlighted = selected;
	self.descriptionLabel.opaque = !selected;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold {
	// Create and configure a label.
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
	
	return [newLabel autorelease];
}

@end
