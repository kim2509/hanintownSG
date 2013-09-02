//
//  ShopCell.m
//  KoreanSG
//
//  Created by Daeyong Kim on 17/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShopCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabelUnderline.h"

@implementation ShopCell

@synthesize shop, parentController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGRect cellTitleRect = CGRectMake( 125,10, 202, 80 );
        UILabel *cellTitleLabel = [[UILabelUnderline alloc] initWithFrame:cellTitleRect];
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
        
        CGRect distanceLabelRect = CGRectMake( 12, 90, 80, 20 );
        UILabel *distanceLabel = [[UILabel alloc] initWithFrame:distanceLabelRect];
        distanceLabel.textAlignment = UITextAlignmentCenter;
        distanceLabel.tag = 3;
        distanceLabel.font = [UIFont fontWithName:@"Arial" size:15];
        distanceLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:distanceLabel];
        [distanceLabel release];
        
        CGRect imageRect = CGRectMake( 12,13, 79, 62 );
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.tag = 4;
        imageButton.frame = imageRect;
        imageButton.layer.masksToBounds = YES;
        imageButton.layer.cornerRadius = 5.0;
        [imageButton addTarget:self action:@selector(imageTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:imageButton];
        
        UIImageView *commentsLikeBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_bg.png"]];
        commentsLikeBG.tag = 5;
        commentsLikeBG.frame = CGRectMake(108, 80, 170, 30);
        [self.contentView addSubview:commentsLikeBG];
        [commentsLikeBG release];
        
        commentsLikeBG.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture2 =
        [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesNCommentsTouched)] autorelease];
        [commentsLikeBG addGestureRecognizer:tapGesture2];
        
        UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [likesButton setBackgroundImage:[UIImage imageNamed:@"thumb_up16.png"] forState:UIControlStateNormal];
        [likesButton addTarget:self action:@selector(likesNCommentsTouched) forControlEvents:UIControlEventTouchUpInside];
        likesButton.frame = CGRectMake(115, 92, 13, 13);
        likesButton.tag = 8;
        [self.contentView addSubview:likesButton];
        
        UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 88, 100, 20)];
        likesLabel.textAlignment = UITextAlignmentLeft;
        likesLabel.tag = 6;
        likesLabel.font = [UIFont systemFontOfSize:11];
        likesLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        likesLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:likesLabel];
        [likesLabel release];
        
        UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentsButton setBackgroundImage:[UIImage imageNamed:@"comment_add16.png"] forState:UIControlStateNormal];
        [commentsButton addTarget:self action:@selector(likesNCommentsTouched) forControlEvents:UIControlEventTouchUpInside];
        commentsButton.frame = CGRectMake(185, 92, 13, 13);
        commentsButton.tag = 9;
        [self.contentView addSubview:commentsButton];
        
        UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 88, 100, 20)];
        commentsLabel.textAlignment = UITextAlignmentLeft;
        commentsLabel.tag = 7;
        commentsLabel.font = [UIFont systemFontOfSize:11];
        commentsLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        commentsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:commentsLabel];
        [commentsLabel release];
        
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setBackgroundImage:[UIImage imageNamed:@"shop32.png"] forState:UIControlStateNormal];
        clickButton.frame = CGRectMake(108,13, 13, 13 );
        [clickButton addTarget:self action:@selector(shopSelected) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:clickButton];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setBackgroundImage:[UIImage imageNamed:@"add16.png"] forState:UIControlStateNormal];
        addButton.frame = CGRectMake(292, 90, 15, 15);
        [addButton addTarget:self action:@selector(addButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addButton];
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
    
    UILabel *likesLabel = (UILabel *) [self viewWithTag:6];
    likesLabel.text = [NSString stringWithFormat:@"%d likes", shop.nLikes];
    
    UILabel *commentsLabel = (UILabel *) [self viewWithTag:7];
    commentsLabel.text = [NSString stringWithFormat:@"%d comments", shop.nComments];
    
    if ( shop.nLikes == 0 && shop.nComments == 0 )
    {
        [self hideCommentsNLikes:YES];
    }
    else
        [self hideCommentsNLikes:NO];
    
    [imageButton setBackgroundImage:[UIImage imageNamed:@"noImage.png"] forState:UIControlStateNormal];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:[Constants shopImageURL:shop.seq]];
    UIImage *cachedImage = [manager imageWithURL:url];
    
    if (cachedImage)
    {
        [imageButton setBackgroundImage:cachedImage forState:UIControlStateNormal];
        shop.bImageExists = YES;
    }
    else
    {
        shop.bImageExists = NO;
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [imageButton setBackgroundImage:image forState:UIControlStateNormal];
    shop.bImageExists = YES;
}

-(void) hideCommentsNLikes:(BOOL) bHide
{
    UIImageView *commentsLikeBG = (UIImageView *) [self viewWithTag:5];
    UIButton *likesButton = (UIButton *) [self viewWithTag:8];
    UILabel *likesLabel = (UILabel *) [self viewWithTag:6];
    UIButton *commentsButton = (UIButton *) [self viewWithTag:9];
    UILabel *commentsLabel = (UILabel *) [self viewWithTag:7];
    
    if ( bHide )
    {
        commentsLikeBG.hidden = YES;
        likesButton.hidden = YES;
        likesLabel.hidden = YES;
        commentsButton.hidden = YES;
        commentsLabel.hidden = YES;
    }
    else
    {
        commentsLikeBG.hidden = NO;
        likesButton.hidden = NO;
        likesLabel.hidden = NO;
        commentsButton.hidden = NO;
        commentsLabel.hidden = NO;
    }
}

-(void) shopSelected
{
    [parentController shopSelect:shop];
}

-(void) imageTouched
{
    [parentController shopImageSelected:shop];
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
