//
//  ShopCell2.m
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopCell2.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShopCell2

@synthesize shop;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGRect cellTitleRect = CGRectMake( 125,10, 202, 80 );
        UILabel *cellTitleLabel = [[UILabel alloc] initWithFrame:cellTitleRect];
        cellTitleLabel.tag = 1;
        cellTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        cellTitleLabel.numberOfLines = 0;
        cellTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self.contentView addSubview:cellTitleLabel];
        [cellTitleLabel release];
        
        cellTitleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shopSelected)] autorelease];
        [cellTitleLabel addGestureRecognizer:tapGesture];
        
        CGRect categoryLabelRect = CGRectMake( 108,55, 202, 20 );
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:categoryLabelRect];
        categoryLabel.textAlignment = UITextAlignmentLeft;
        categoryLabel.tag = 2;
        categoryLabel.font = [UIFont fontWithName:@"Arial" size:11];
        categoryLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:categoryLabel];
        [categoryLabel release];
        
        CGRect imageRect = CGRectMake( 12,13, 79, 62 );
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.tag = 4;
        imageButton.frame = imageRect;
        imageButton.layer.masksToBounds = YES;
        imageButton.layer.cornerRadius = 5.0;
        [imageButton addTarget:self action:@selector(imageTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:imageButton];
                
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setBackgroundImage:[UIImage imageNamed:@"shop32.png"] forState:UIControlStateNormal];
        clickButton.frame = CGRectMake(108,13, 13, 13 );
        [clickButton addTarget:self action:@selector(shopSelected) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:clickButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setData:(Shop *) s
{
    self.shop = s;
    
    UILabel *title = (UILabel *) [self viewWithTag:1];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor colorWithHexString:@"#3b5999"];
    CGRect cellTitleRect = CGRectMake(125,10, 202, 80);
    title.frame = cellTitleRect;
    
    title.text = shop.shopName;
    
    CGSize labelSize = [title.text sizeWithFont:title.font 
                              constrainedToSize:title.frame.size 
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    title.frame = CGRectMake(title.frame.origin.x,
                             title.frame.origin.y, 
                             labelSize.width, 
                             labelSize.height );
    
    UILabel *categoryLabel = (UILabel *) [self viewWithTag:2];
    categoryLabel.text = shop.category;
    
    UILabel *distanceLabel = (UILabel *) [self viewWithTag:3];
    
    if ( shop.latitude != kLocationEmpty )
        distanceLabel.text = shop.distance;
    else
        distanceLabel.text = @"";
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:[Constants shopImageURL:shop.seq]];
    UIImage *cachedImage = [manager imageWithURL:url];
    
    if (cachedImage)
    {
        [imageButton setBackgroundImage:cachedImage forState:UIControlStateNormal];
    }
    else
    {
        [imageButton setBackgroundImage:[UIImage imageNamed:@"noImage.png"] forState:UIControlStateNormal];
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [imageButton setBackgroundImage:image forState:UIControlStateNormal];
}

-(void) shopSelected
{
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

-(void) likesNCommentsTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewLikesNComments" object:shop];
}

- (void)dealloc {
    [shop release];
    [super dealloc];
}

@end
