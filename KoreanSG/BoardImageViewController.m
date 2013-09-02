//
//  BoardImageViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 13/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoardImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BoardImageViewController ()

@end

@implementation BoardImageViewController

@synthesize imgURL, boardName, subject, bID, userID;

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

    imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.tag = 4;
    imageButton.frame = CGRectMake(0, 5, 120, 80);
    imageButton.layer.masksToBounds = YES;
    imageButton.layer.cornerRadius = 5.0;
    [imageButton addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 120, 20)];
    label.text = subject;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:label];
    [label release];
    
    if ( av == nil )
    {
        av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    av.frame=CGRectMake(35, 25, 50, 50);
    av.tag  = 1;
    [self.view addSubview:av];
    [av startAnimating];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:imgURL];
    //    UIImage *cachedImage = [manager imageWithURL:url];
    
    [manager downloadWithURL:url delegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [av removeFromSuperview];
    [imageButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error
{
    [av removeFromSuperview];
}

- (void) selectImage
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [dict setValue:boardName forKey:@"boardName"];
    [dict setValue:bID forKey:@"postID"];
    [dict setValue:userID forKey:@"userID"];
    [dict setValue:subject forKey:@"subject"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageViewTouched" object:dict];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.imgURL = nil;
    self.boardName = nil;
    self.subject = nil;
    self.userID = nil;
    self.bID = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [imgURL release];
    [boardName release];
    [subject release];
    [userID release];
    [bID release];
    [super dealloc];
}
@end