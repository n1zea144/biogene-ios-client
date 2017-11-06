#import <UIKit/UIKit.h>
@class Gene;

@interface SearchResultsCell : UITableViewCell {

@private	
	Gene *gene;
    UILabel *symbolLabel;
	UILabel *organismLabel;
    UILabel *descriptionLabel;
}

- (Gene *)gene;
- (void)setGene:(Gene *)newGene;

@end
