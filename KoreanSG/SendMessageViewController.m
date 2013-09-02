//
//  SendMessageViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 21/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendMessageViewController.h"

@interface SendMessageViewController ()

@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect 
{
    //UIColor *color = [UIColor clearColor];
    UIImage *img  = [UIImage imageNamed: @"main_top_bg.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.tintColor = color;
}
@end

@implementation SendMessageViewController

@synthesize senderField,messageView, receiverID, receiverNickname;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *cancelButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    cancelButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [cancelButtonCustom addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"취소";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [cancelButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonCustom];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *writeButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    writeButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [writeButtonCustom addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                            initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel2.text = @"전송";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [writeButtonCustom addSubview:titleLabel2];
    [titleLabel2 release];
    
    UIBarButtonItem *writeButton = [[UIBarButtonItem alloc] initWithCustomView:writeButtonCustom];
    self.navigationItem.rightBarButtonItem = writeButton;
    [writeButton release];
    
    self.title = @"메세지 보내기";
    
    [self createControls];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(userSelected:) name:@"UserSelected" object:nil];
}

- (void)setTitle:(NSString *)title
{    
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = [UIColor colorWithHexString:@"#141414"];
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

-(void) cancel
{
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

-(void) post
{
    if ( receiverID == nil || [receiverID isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:@"받는사람을 지정해주십시오." 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    if ( messageView.text == nil || [messageView.text isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:@"메세지의 내용이 없습니다." 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    
    NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
    [reqDict setValue:[[DataManager sharedDataManager] metaInfoString:@"USER_ID"] forKey:@"fromUserID"];
    [reqDict setValue:receiverID forKey:@"toUserID"];
    [reqDict setValue:messageView.text forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessage" object:reqDict];
}

-(void) createControls
{
    UILabel* toLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(8, 5, 40, 32 )];
    toLabel.text = @"To :";
    toLabel.font = [UIFont systemFontOfSize:18.0];
    toLabel.textColor = [UIColor colorWithHexString:@"#787878"];
    toLabel.backgroundColor = [UIColor clearColor];
    toLabel.textAlignment = UITextAlignmentLeft;
    
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    [self.view addSubview:separator];
    [separator release];

    [self.view addSubview:toLabel];
    
    senderField = [[UITextField alloc] initWithFrame:CGRectMake(45, 6, 260, 30)];
    senderField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:senderField];
    senderField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [senderField release];

    messageView = [[UITextView alloc] initWithFrame:CGRectMake(2, 45, 300, 150)];
    messageView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:messageView];
    
    senderField.delegate = self;
    
    if ( receiverID != nil && [@"" isEqualToString:receiverID] == NO )
    {
        senderField.text = [NSString stringWithFormat:@"%@(%@)", receiverNickname, receiverID];
        senderField.enabled = NO;
        [messageView becomeFirstResponder];
    }
    else {
        UIButton *contactsAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [contactsAddButton addTarget:self action:@selector(contactsTouched) forControlEvents:UIControlEventTouchUpInside];
        senderField.enabled = YES;
        senderField.rightView = contactsAddButton;
        senderField.rightViewMode=UITextFieldViewModeAlways;
    }
    
    [messageView becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}


-(void) contactsTouched
{
    [super openUserListViewController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) userSelected:(NSNotification *)notification
{
    NSMutableDictionary *dict = notification.object;
    self.receiverID = [dict objectForKey:@"selectedUserID"];
    self.receiverNickname = [dict objectForKey:@"selectedUserNickname"];
    senderField.text = [NSString stringWithFormat:@"%@(%@)", receiverNickname, receiverID];
}

@end
