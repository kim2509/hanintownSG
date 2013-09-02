//
//  LoginInputViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 24/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginInputViewController.h"

@interface LoginInputViewController ()

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

@implementation LoginInputViewController

@synthesize activeField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_top_bg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    self.title = @"로그인";
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
    titleLabel2.text = @"계정";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel2];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
    
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *submitButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    submitButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [submitButtonCustom addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel.text = @"전송";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    [submitButtonCustom addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithCustomView:submitButtonCustom];
    self.navigationItem.rightBarButtonItem = submitButton;
    [submitButton release];
    
    informLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 25)];
    informLabel.textAlignment = UITextAlignmentCenter;
    informLabel.backgroundColor = [UIColor clearColor];
    informLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:informLabel];
    [informLabel release];
    
    informLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 155, 320, 25)];
    informLabel2.textAlignment = UITextAlignmentCenter;
    informLabel2.backgroundColor = [UIColor clearColor];
    informLabel2.font = [UIFont systemFontOfSize:15];
    informLabel2.textColor = [UIColor redColor];
    [self.view addSubview:informLabel2];
    [informLabel2 release];
}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) submit
{
    @try {
                
        NSMutableDictionary *reqDict = [[NSMutableDictionary alloc] init];
        
        UITextField *textField = (UITextField *) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:1];
        if ( textField.text == nil || [textField.text isEqualToString:@""] )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"회원가입오류" message:@"아이디를 입력해 주십시오." 
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [textField becomeFirstResponder];
            return;
        }
        
        [reqDict setValue:textField.text forKey:@"userID"];
        
        textField = (UITextField *) [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:2];
        if ( textField.text == nil || [textField.text isEqualToString:@""] )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"회원가입오류" message:@"비밀번호를 입력해 주십시오." 
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] 
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [textField becomeFirstResponder];
            return;
        }
        
        [reqDict setValue:textField.text forKey:@"password"];
        
        [[TransactionManager sharedManager] login:reqDict];
        
        [activeField resignFirstResponder];
    }
    @catch (NSException *exception) {
        NSLog(@"[login-exception] %@", exception );
    }
    @finally {
        
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginSent:) name:@"loginSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginReceived:) name:@"loginReceived" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
        playerTextField.adjustsFontSizeToFitWidth = YES;
        playerTextField.textColor = [UIColor blackColor];
        if ([indexPath row] == 0) {
            playerTextField.placeholder = @"아이디";
            playerTextField.keyboardType = UIKeyboardTypeEmailAddress;
            playerTextField.returnKeyType = UIReturnKeyNext;
        }
        else {
            playerTextField.placeholder = @"비밀번호";
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.secureTextEntry = YES;
            playerTextField.returnKeyType = UIReturnKeySend;
        }       
        playerTextField.backgroundColor = [UIColor clearColor];
        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        playerTextField.textAlignment = UITextAlignmentLeft;
        playerTextField.tag = indexPath.row + 1;
        playerTextField.delegate = self;
        
        playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [playerTextField setEnabled: YES];
        
        [cell addSubview:playerTextField];
        [playerTextField release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    activeField = sender;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    @try {
        if ( [theTextField returnKeyType] == UIReturnKeyNext )
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theTextField.tag inSection:0]];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:theTextField.tag inSection:0] 
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            UITextField *textField = (UITextField *)[cell viewWithTag:theTextField.tag+1];
            [textField becomeFirstResponder];
        }
        if ( [theTextField returnKeyType] == UIReturnKeySend )
        {
            [self submit];
        }
        else {
            [theTextField resignFirstResponder];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
        
    return YES;
}


-(void) loginSent:(NSNotification *)notification
{
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
          :UIActivityIndicatorViewStyleGray];
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];
}

-(void) setUserData:(NSMutableDictionary *) resDict
{
    [[DataManager sharedDataManager] setMetaInfo:@"USER_ID" value:[resDict objectForKey:@"USER_ID"]];
    [[DataManager sharedDataManager] setMetaInfo:@"PASSWORD" value:[resDict objectForKey:@"PASSWORD"]];
    [[DataManager sharedDataManager] setMetaInfo:@"NICKNAME" value:[resDict objectForKey:@"NICKNAME"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_NO" value:[resDict objectForKey:@"USER_NO"]];
    [[DataManager sharedDataManager] setMetaInfo:@"EMAIL" value:[resDict objectForKey:@"EMAIL"]];
    [[DataManager sharedDataManager] setMetaInfo:@"LAST_LOGIN_TIME" value:[resDict objectForKey:@"LAST_LOGIN_TIME"]];
}

-(void) loginReceived:(NSNotification *)notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            resDict = [resDict objectForKey:@"resultBody"];
            informLabel.textColor = [UIColor blueColor];
            informLabel.text = [NSString stringWithFormat:@"어서오십시오. %@ 님.", [resDict objectForKey:@"NICKNAME"]];
            informLabel2.text = @"";
            [self setUserData:resDict];
            [self performSelector:@selector(afterHTTPReceived:) withObject:resDict afterDelay:0.5];
        }
        else if ([ErrCodeFail isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            informLabel.textColor = [UIColor redColor];
            informLabel.text = @"서버와 통신이 원활하지 않습니다.";
            informLabel2.text = [NSString stringWithFormat:@"잠시 후 다시 시도해 주십시오.(%@)", [resDict objectForKey:@"resCode"]];
        }
        else {
            informLabel.textColor = [UIColor redColor];
            informLabel.text = [resDict objectForKey:@"resMsg"];
            informLabel2.text = [NSString stringWithFormat:@"확인후 다시 입력해 주십시오.(%@)", [resDict objectForKey:@"resCode"]];
        }   
    }
    @catch (NSException *exception) {
        NSLog(@"[httpRequestReceived exception]: %@", exception);
    }
    @finally {
        
    }
}

-(void) afterHTTPReceived:(NSMutableDictionary *) resDict
{
    [[DataManager sharedDataManager] setMetaInfo:@"NICKNAME" value:[resDict objectForKey:@"NICKNAME"]];
    [[DataManager sharedDataManager] setMetaInfo:@"EMAIL" value:[resDict objectForKey:@"EMAIL"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_ID" value:[resDict objectForKey:@"USER_ID"]];
    [[DataManager sharedDataManager] setMetaInfo:@"USER_NO" value:[resDict objectForKey:@"USER_NO"]];
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceeded" object:nil];
}

@end
