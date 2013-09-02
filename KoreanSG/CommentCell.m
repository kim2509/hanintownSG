//
//  CommentCell.m
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "common.h"

@implementation CommentCell

@synthesize height,object;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView *commentsLikeBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_add16.png"]];
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
        
        UILabel *deleteLabel = [[UILabel alloc] init];
        deleteLabel.textAlignment = UITextAlignmentLeft;
        deleteLabel.tag = 3;
        deleteLabel.font = [UIFont boldSystemFontOfSize:13];
        deleteLabel.textAlignment = UITextAlignmentRight;
        deleteLabel.textColor = [UIColor colorWithHexString:@"#405776"];
        deleteLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:deleteLabel];
        [deleteLabel release];
        
        deleteLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteComment)] autorelease];
        [deleteLabel addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setComment:(NSString *)comment delete:(BOOL) bDelete
{
    UILabel *title = (UILabel *) [self viewWithTag:2];
    CGRect cellTitleRect = CGRectMake( 32, 10 , 245, 500 );
    title.frame = cellTitleRect;
    title.text = comment;
    
    CGSize labelSize = [title.text sizeWithFont:title.font 
                              constrainedToSize:title.frame.size 
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    title.frame = CGRectMake(title.frame.origin.x,
                             title.frame.origin.y, 
                             labelSize.width, 
                             labelSize.height );
    
    if ( bDelete )
    {
        UILabel *deleteLabel = (UILabel *) [self viewWithTag:3];
        deleteLabel.text = @"삭제";
        deleteLabel.frame = CGRectMake( 250, 7, 60, 20);
        deleteLabel.hidden = NO;
    }
    else
    {
        UILabel *deleteLabel = (UILabel *) [self viewWithTag:3];
        deleteLabel.text = @"";
        deleteLabel.hidden = YES;
    }
    
    self.height = labelSize.height;
}

-(void) deleteComment
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteComment" object:object];
}

- (void)dealloc {
    [object release];
    self.object = nil;
    [super dealloc];
}

@end
