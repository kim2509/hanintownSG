//
//  SendMessageViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 21/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface SendMessageViewController : DYViewController<UITextFieldDelegate>
{
    UITextField *senderField;
    UITextView *messageView;
    NSString *receiverID;
    NSString *receiverNickname;
}

@property(nonatomic, retain) UITextField *senderField;
@property(nonatomic, retain) UITextView *messageView;
@property(nonatomic, retain) NSString *receiverID;
@property(nonatomic, retain) NSString *receiverNickname;

-(void) createControls;

@end
