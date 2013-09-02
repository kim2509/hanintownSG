//
//  CommentCell.h
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
{
    float height;
    NSObject *object;
}

@property(nonatomic) float height;
@property(nonatomic, retain) NSObject *object;

-(void) setComment:(NSString *)comment delete:(BOOL) bDelete;

@end
