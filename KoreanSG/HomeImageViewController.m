//
//  HomeImageViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 13/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeImageViewController ()

@end

@implementation HomeImageViewController

@synthesize imageURL, boardName, subject, bID, userID;

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
    imageButton.frame = CGRectMake(5, 5, 310, 140);
    imageButton.layer.masksToBounds = YES;
    imageButton.layer.cornerRadius = 5.0;
    [imageButton addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    if ( av == nil )
    {
        av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    av.frame=CGRectMake(135, 45, 50, 50);
    av.tag  = 1;
    [self.view addSubview:av];
    [av startAnimating];
    
    [self reloadImage];
}

- (void) reloadImage
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:imageURL];
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
    
    self.imageURL = nil;
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
    [imageURL release];
    [boardName release];
    [subject release];
    [userID release];
    [bID release];
    [super dealloc];
}
@end
