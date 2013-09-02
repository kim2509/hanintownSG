//
//  CommentInputViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 29/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentInputViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommentInputViewController

@synthesize inputComment;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Comment";
    
    self.view.backgroundColor = [UIColor blackColor];
    
    inputComment = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 180)];
    self.inputComment.font = [UIFont systemFontOfSize:16];
    self.inputComment.contentInset = UIEdgeInsetsMake(4,8,0,0);
    
    self.inputComment.backgroundColor = [UIColor whiteColor];
    
    self.inputComment.layer.cornerRadius = 10.0;
    
    [self.view addSubview:inputComment];
    
    UIBarButtonItem *cancelButon = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButon;
    [cancelButon release];
    
    UIBarButtonItem *postButon = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem = postButon;
    [postButon release];
    
    [self.inputComment becomeFirstResponder];
}

-(void) cancel
{
    [[self navigationController] dismissModalViewControllerAnimated:NO];
}

-(void) post
{
    [[self navigationController] dismissModalViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddComment" object:self.inputComment.text];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.inputComment = nil;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [inputComment release];
    [super dealloc];
}

@end
