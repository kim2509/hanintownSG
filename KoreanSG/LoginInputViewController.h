//
//  LoginInputViewController.h
//  KoreanSG
//
//  Created by Daeyong Kim on 24/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@interface LoginInputViewController : UITableViewController<UITextFieldDelegate>
{
    UITextField *activeField;
    UIActivityIndicatorView *av;
    UILabel *informLabel;
    UILabel *informLabel2;
}

@property(nonatomic, retain) UITextField *activeField;

@end
