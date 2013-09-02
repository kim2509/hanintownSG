//
//  LikCell.m
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LikeCell.h"

@implementation LikeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView *commentsLikeBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb_up16.png"]];
        commentsLikeBG.tag = 1;
        commentsLikeBG.frame = CGRectMake(10, 10, 16, 16);
        [self.contentView addSubview:commentsLikeBG];
        [commentsLikeBG release];
        
        UILabel *cellTitleLabel = [[UILabel alloc] init];
        cellTitleLabel.tag = 2;
        cellTitleLabel.font = [UIFont systemFontOfSize:14];
        cellTitleLabel.numberOfLines = 0;
        cellTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        cellTitleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:cellTitleLabel];
        [cellTitleLabel release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setLikeText:(NSString *)likeText
{
    UILabel *title = (UILabel *) [self viewWithTag:2];
    CGRect cellTitleRect = CGRectMake( 32, 10 , 310 - 40, 500 );
    title.frame = cellTitleRect;
    title.text = likeText;
    
    CGSize labelSize = [title.text sizeWithFont:title.font 
                              constrainedToSize:title.frame.size 
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    title.frame = CGRectMake(title.frame.origin.x,
                             title.frame.origin.y, 
                             labelSize.width, 
                             labelSize.height );
}

@end
