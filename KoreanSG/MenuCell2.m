//
//  MenuCell2.m
//  KoreanSG
//
//  Created by Daeyong Kim on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCell2.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuCell2

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
        
        CGRect menuTypeLabelRect = CGRectMake( 108,55, 50, 20 );
        UILabel *menuTypeLabel = [[UILabel alloc] initWithFrame:menuTypeLabelRect];
        menuTypeLabel.textAlignment = UITextAlignmentLeft;
        menuTypeLabel.tag = 2;
        menuTypeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        menuTypeLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:menuTypeLabel];
        [menuTypeLabel release];
        
        CGRect priceLabelRect = CGRectMake( 12, 90, 80, 20 );
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:priceLabelRect];
        priceLabel.textAlignment = UITextAlignmentCenter;
        priceLabel.tag = 3;
        priceLabel.font = [UIFont fontWithName:@"Arial" size:15];
        priceLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        [self.contentView addSubview:priceLabel];
        [priceLabel release];
        
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
        [clickButton setBackgroundImage:[UIImage imageNamed:@"food16.png"] forState:UIControlStateNormal];
        clickButton.frame = CGRectMake(108,13, 13, 13 );
        [self.contentView addSubview:clickButton];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setBackgroundImage:[UIImage imageNamed:@"add16.png"] forState:UIControlStateNormal];
        addButton.frame = CGRectMake(295, 90, 15, 15);
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
    menuTypeLabel.text = menu.menuType;
    
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
    
    
    
    UILabel *likesLabel = (UILabel *) [self viewWithTag:6];
    likesLabel.text = [NSString stringWithFormat:@"%d likes", menu.nLikes];
    
    UILabel *commentsLabel = (UILabel *) [self viewWithTag:7];
    commentsLabel.text = [NSString stringWithFormat:@"%d comments", menu.nComments];
    
    if ( menu.nLikes == 0 && menu.nComments == 0 )
    {
        [self hideCommentsNLikes:YES];
    }
    else
        [self hideCommentsNLikes:NO];
    
    [imageButton setBackgroundImage:[UIImage imageNamed:@"noImage.png"] forState:UIControlStateNormal];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:[Constants menuImageURL:menu.menuSeq]];
    
    UIImage *cachedImage = [manager imageWithURL:url];
    
    if (cachedImage)
    {
        [imageButton setBackgroundImage:cachedImage forState:UIControlStateNormal];
    }
    else
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [imageButton setBackgroundImage:image forState:UIControlStateNormal];
}

-(void) imageTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuImageSelected" object:menu];
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
