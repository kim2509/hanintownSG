//
//  MenuGroupCell.m
//  KoreanSG
//
//  Created by Daeyong Kim on 18/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuGroupCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setBackgroundImage:[UIImage imageNamed:@"food16.png"] forState:UIControlStateNormal];
        clickButton.frame = CGRectMake(108,13, 13, 13 );
        [clickButton addTarget:self action:@selector(menuSelected) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:clickButton];
        
        CGRect cellTitleRect = CGRectMake( 125,10, 212, 70 );
        UILabel *cellTitleLabel = [[UILabel alloc] initWithFrame:cellTitleRect];
        cellTitleLabel.tag = 1;
        cellTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        cellTitleLabel.numberOfLines = 0;
        cellTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        cellTitleLabel.textColor = [UIColor colorWithHexString:@"#3b5999"];
        [self.contentView addSubview:cellTitleLabel];
        [cellTitleLabel release];
        
        CGRect menuTypeLabelRect = CGRectMake( 108,60, 70, 20 );
        UILabel *menuTypeLabel = [[UILabel alloc] initWithFrame:menuTypeLabelRect];
        menuTypeLabel.textAlignment = UITextAlignmentLeft;
        menuTypeLabel.tag = 2;
        menuTypeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        menuTypeLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:menuTypeLabel];
        [menuTypeLabel release];
        
        CGRect priceLabelRect = CGRectMake( 220,60, 80, 20 );
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceLabelRect];
        priceLabel.textAlignment = UITextAlignmentRight;
        priceLabel.tag = 3;
        priceLabel.font = [UIFont fontWithName:@"Arial" size:15];
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
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setData:(MenuGroup *)menuGroup
{
    UILabel *title = (UILabel *) [self viewWithTag:1];
    title.text = [NSString stringWithFormat:@"%@(%d)", menuGroup.menuName, menuGroup.count ];
    
    CGRect cellTitleRect = CGRectMake( 125,10, 212, 70 );
    title.frame = cellTitleRect;
    
    CGSize labelSize = [title.text sizeWithFont:title.font 
                              constrainedToSize:title.frame.size 
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    title.frame = CGRectMake(title.frame.origin.x,
                             title.frame.origin.y, 
                             labelSize.width, 
                             labelSize.height );
    
    //    UILabel *menuTypeLabel = (UILabel *) [cell viewWithTag:2];
    //    menuTypeLabel.text = [NSString stringWithFormat:@"[%@]",menu.shopName];
    
    //    UILabel *priceLabel = (UILabel *) [cell viewWithTag:3];
    //    priceLabel.text = [NSString stringWithFormat:@"%@%0.1f", menu.currency ,menu.price];
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:4];
    
    UIImage *image = [UIImage imageNamed:[menuGroup.menuName stringByAppendingString:@".png"]];
    if ( image == nil )
        image = [UIImage imageNamed:@"noImage.png"];
    
    imageView.image = image;

}
/*
-(void) shopSelected
{
    UILabel *title = (UILabel *) [self viewWithTag:1];
    title.backgroundColor = [UIColor colorWithHexString:@"#d8dfea"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopSelect" object:shop];
}

-(void) imageTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopSelect" object:shop];
}

-(void) addButtonTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddLikesNComments" object:shop];
}
*/

@end
