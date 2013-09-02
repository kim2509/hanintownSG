//
//  MenuCell3.m
//  KoreanSG
//
//  Created by Daeyong Kim on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCell3.h"
#import "common.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuCell3

@synthesize menu;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGRect cellTitleRect = CGRectMake( 125,10, 192, 70 );
        UILabel *cellTitleLabel = [[UILabel alloc] initWithFrame:cellTitleRect];
        cellTitleLabel.tag = 1;
        cellTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        cellTitleLabel.numberOfLines = 0;
        cellTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self.contentView addSubview:cellTitleLabel];
        [cellTitleLabel release];
        
        CGRect menuTypeLabelRect = CGRectMake( 108,55, 130, 20 );
        UILabel *menuTypeLabel = [[UILabel alloc] initWithFrame:menuTypeLabelRect];
        menuTypeLabel.textAlignment = UITextAlignmentLeft;
        menuTypeLabel.tag = 2;
        menuTypeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        menuTypeLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:menuTypeLabel];
        [menuTypeLabel release];
        
        CGRect priceLabelRect = CGRectMake( 250,55, 50, 20 );
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceLabelRect];
        priceLabel.textAlignment = UITextAlignmentRight;
        priceLabel.tag = 3;
        priceLabel.font = [UIFont fontWithName:@"Arial" size:11];
        priceLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:priceLabel];
        [priceLabel release];
        
        CGRect imageRect = CGRectMake( 12,13, 79, 62 );
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.tag = 4;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 5.0;
        [self.contentView addSubview:imageView];
        [imageView release];
        
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setBackgroundImage:[UIImage imageNamed:@"food16.png"] forState:UIControlStateNormal];
        clickButton.frame = CGRectMake(108,13, 13, 13 );
        [self.contentView addSubview:clickButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setData:(Menu *)m shop:(Shop *)shop bNeverShowPrice:(BOOL) bNeverShowPrice
{
    self.menu = m;
    
    UILabel *cellTitleLabel = (UILabel *) [self viewWithTag:1];
    
    if ( [menu.menuUnit isEqualToString:@""] == NO )
    {
        cellTitleLabel.text = [NSString stringWithFormat:@"%@ (%@)",[menu menuName], [menu menuUnit]];
    }
    else
        cellTitleLabel.text = menu.menuName;
    
    CGRect cellTitleRect = CGRectMake( 125,10, 192, 70 );
    cellTitleLabel.frame = cellTitleRect;
    
    CGSize labelSize = [cellTitleLabel.text sizeWithFont:cellTitleLabel.font 
                                       constrainedToSize:cellTitleLabel.frame.size 
                                           lineBreakMode:UILineBreakModeWordWrap];
    
    cellTitleLabel.frame = CGRectMake(cellTitleLabel.frame.origin.x,
                                      cellTitleLabel.frame.origin.y, 
                                      labelSize.width, 
                                      labelSize.height );
    
    UILabel *menuTypeLabel = (UILabel *) [self viewWithTag:2];
    menuTypeLabel.text = [NSString stringWithFormat:@"[%@]  [%@]",shop.shopName, menu.menuType];
    
    if ( bNeverShowPrice == NO && shop.bShowPrice )
    {
        UILabel *priceLabel = (UILabel *) [self viewWithTag:3];
        priceLabel.text = [NSString stringWithFormat:@"%@%0.1f",[menu currency], [menu price]];
    }
    else
    {
        UILabel *priceLabel = (UILabel *) [self viewWithTag:3];
        priceLabel.text = @"";
    }
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:4];
    
    [imageView setImageWithURL:[NSURL URLWithString:[Constants menuImageURL:menu.menuSeq]]
              placeholderImage:[UIImage imageNamed:@"noImage.png"]];
}

-(void) addButtonTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddLikesNComments" object:menu];
}

-(void) likesNCommentsTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewLikesNComments" object:menu];
}

- (void)dealloc {
    [menu release];
    [super dealloc];
}

@end
