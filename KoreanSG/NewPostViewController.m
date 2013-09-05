//
//  NewPostViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CategorySelectViewController.h"

@interface NewPostViewController ()

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

@implementation NewPostViewController

@synthesize inputTextView, postTitle, content, tableData, boardName, selectedCategoryID, selectedCategoryName;

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
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *writeButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButtonCustom setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    writeButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [writeButtonCustom addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    titleLabel2.text = @"작성";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [writeButtonCustom addSubview:titleLabel2];
    [titleLabel2 release];
    
    UIBarButtonItem *writeButton = [[UIBarButtonItem alloc] initWithCustomView:writeButtonCustom];
    self.navigationItem.rightBarButtonItem = writeButton;
    
    
    // create controls
    postTitleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, 310, 30)];
    postTitleField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:postTitleField];
    
    postTitleField.backgroundColor = [UIColor whiteColor];
    postTitleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    postTitleField.placeholder = @"제목";
    postTitleField.delegate = self;
    
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    [self.view addSubview:separator];
    [separator release];

    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 45, 300, 100)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        inputTextView.frame = CGRectMake(inputTextView.frame.origin.x, inputTextView.frame.origin.y ,
                                         inputTextView.frame.size.width, inputTextView.frame.size.height + 90 );
    }
    
    [self.inputTextView release];
    inputTextView.font = [UIFont systemFontOfSize:16];
    
    self.inputTextView.backgroundColor = [UIColor whiteColor];        
    
    self.inputTextView.text = @"내용";
    self.inputTextView.textColor = [UIColor lightGrayColor];
    self.inputTextView.delegate = self;
    
    if ( content != nil && [@"" isEqualToString:content] == NO )
    {
        inputTextView.text = content;
        self.inputTextView.textColor = [UIColor blackColor];
    }
    
    [self.view addSubview:inputTextView];
    
    [postTitleField becomeFirstResponder];
    
    customToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 160, 320, 260)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        customToolBar.frame = CGRectMake(customToolBar.frame.origin.x, customToolBar.frame.origin.y + 90 ,
                                       customToolBar.frame.size.width, customToolBar.frame.size.height );
    }
    
    customToolBar.backgroundColor = [UIColor colorWithHexString:@"#D3D1D2"];
    [self.view addSubview:customToolBar];
    
    UIImage *btnPicImage = [UIImage imageNamed:@"btn_bg02.png"];
    UIButton *btnPic = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPic setBackgroundImage:btnPicImage forState:UIControlStateNormal];
    btnPic.frame = CGRectMake(5, 4, 63, 32);
    [btnPic addTarget:self action:@selector(getImage) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* btnTitle = [[UILabel alloc] 
                           initWithFrame:CGRectMake(0, 0, 63, 32 )];
    btnTitle.text = @"사진첨부";
    btnTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    btnTitle.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    btnTitle.backgroundColor = [UIColor clearColor];
    btnTitle.textAlignment = UITextAlignmentCenter;
    
    [btnPic addSubview:btnTitle];
    [btnTitle release];
    
    [customToolBar addSubview:btnPic];
    
    if ( tableData == nil )
    {
        tableData = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"BODYTEXT" forKey:@"content"];
        [dict setValue:@"TEXT" forKey:@"TYPE"];
        [dict setValue:@"0" forKey:@"VERTICAL_ORDER"];
        [tableData addObject:dict];
        [dict release];
    }
    
    UIView *categorySelectView = [[UIView alloc] initWithFrame:CGRectMake(170, 6, 80, 28)];
    categorySelectView.layer.cornerRadius = 5.0;
    categorySelectView.backgroundColor = [UIColor colorWithHexString:@"#EBEDF3"];
    categorySelectView.layer.borderColor = [UIColor colorWithHexString:@"#003366"].CGColor;
    categorySelectView.layer.borderWidth = 0.5f;
    categorySelectView.userInteractionEnabled = YES;
    UITapGestureRecognizer *editGesture =
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCategory)] autorelease];
    [categorySelectView addGestureRecognizer:editGesture];
    
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 80, 20)];
    categoryLabel.textAlignment = UITextAlignmentCenter;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont boldSystemFontOfSize:14];
    
    NSString *category = @"";
    
    self.title = @"새 글";
    if ( postTitle != nil && [@"" isEqualToString:postTitle] == NO )
    {
        self.title = @"수정";
        postTitleField.text = postTitle;
        modifyInfoDict = [[NSMutableDictionary alloc] init];
        category = selectedCategoryName;
    }
    else {

        self.selectedCategoryID = [[DataManager sharedDataManager] metaInfoString:
                              [NSString stringWithFormat:@"%@_CATEGORY_ID", boardName]];
        self.selectedCategoryName = [[DataManager sharedDataManager] metaInfoString:
                              [NSString stringWithFormat:@"%@_CATEGORY_NAME", boardName]];
        
        category = selectedCategoryName;
        if ( [category isEqualToString:@"전체"] )
            category = @"";
    }
    
    NSMutableArray *boardCategoryList = [DYViewController getBoardCategoryList:boardName showOptional:NO];
    
    if ( category == nil || [category isEqualToString:@""] )
    {
        self.selectedCategoryID = @"";
        self.selectedCategoryName = @"";
        category = @"분류미지정";
        
        if ( boardCategoryList != nil && [boardCategoryList count] == 1 )
        {
            self.selectedCategoryID = [[boardCategoryList objectAtIndex:0] valueForKey:@"ID"];
            self.selectedCategoryName = [[boardCategoryList objectAtIndex:0] valueForKey:@"CATEGORY_NAME"];
            category = self.selectedCategoryName;
        }
    }
    
    categoryLabel.text = [NSString stringWithFormat:@"%@", category];
    categoryLabel.textColor = [UIColor colorWithHexString:@"#003366"];
    [categorySelectView addSubview:categoryLabel];
    [customToolBar addSubview:categorySelectView];
    
    pictureInfoView = [[UIView alloc] initWithFrame:CGRectMake(255, 6, 60, 28)];
    pictureInfoView.layer.cornerRadius = 5.0;
    pictureInfoView.backgroundColor = [UIColor colorWithHexString:@"#EBEDF3"];
    pictureInfoView.layer.borderColor = [UIColor colorWithHexString:@"#003366"].CGColor;
    pictureInfoView.layer.borderWidth = 0.5f;
    pictureInfoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *editGesture2 =
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPictures)] autorelease];
    [pictureInfoView addGestureRecognizer:editGesture2];
    
    pictureNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 50, 20)];
    pictureNumberLabel.backgroundColor = [UIColor clearColor];
    pictureNumberLabel.font = [UIFont boldSystemFontOfSize:14];
    pictureNumberLabel.text = [NSString stringWithFormat:@"사진 %d", [tableData count] - 1];
    pictureNumberLabel.textColor = [UIColor colorWithHexString:@"#003366"];
    [pictureInfoView addSubview:pictureNumberLabel];
    [customToolBar addSubview:pictureInfoView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(categoryChanged:) name:@"SetCategory" object:nil];

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

-(void) changeCategory
{
    CategorySelectViewController *categorySelectViewController = [[CategorySelectViewController alloc] init];
    categorySelectViewController.boardName = boardName;
    categorySelectViewController.callFrom = @"newPost";
    categorySelectViewController.categoryID = selectedCategoryID;
    UINavigationController *categorySelectNavViewController = 
    [[UINavigationController alloc] initWithRootViewController:categorySelectViewController];
    [categorySelectViewController release];
    [[self navigationController] presentModalViewController:categorySelectNavViewController animated:YES];
    [categorySelectNavViewController release];
}

-(void) categoryChanged:(NSNotification *) notification
{
    self.selectedCategoryID = [notification.object objectForKey:@"SELECTED_CATEGORY_ID"];
    self.selectedCategoryName = [notification.object objectForKey:@"SELECTED_CATEGORY_NAME"];
    
    categoryLabel.text = selectedCategoryName;
}

-(void) post
{
    if ( postTitleField.text == nil || [postTitleField.text isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"제목을 입력해 주십시오." 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    if ( inputTextView.text == nil || [inputTextView.text isEqualToString:@""] ||
        [inputTextView.text isEqualToString:@"내용"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"내용을 입력해 주십시오." 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert autorelease];
        return;
    }
    
    if ( categoryLabel.text == nil || [categoryLabel.text isEqualToString:@""] ||
        [categoryLabel.text isEqualToString:@"분류미지정"])
    {
        [self changeCategory];
        return;
    }
    
    [[self navigationController] dismissModalViewControllerAnimated:YES];
    
    // new
    if ( postTitle == nil || [@"" isEqualToString:postTitle] )
    {
        NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
        [reqDict setValue:postTitleField.text forKey:@"subject"];
        [reqDict setValue:inputTextView.text forKey:@"content"];
        [reqDict setValue:selectedCategoryID forKey:@"categoryID"];
        [reqDict setValue:boardName forKey:@"boardName"];
        
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        
        for ( int i = 0; i < [tableData count]; i++ )
        {
            NSMutableDictionary *dict = [tableData objectAtIndex:i];
            
            if ( [[dict objectForKey:@"TYPE"] isEqualToString:@"IMAGE"] )
            {
                UIImage *image = [dict objectForKey:@"IMAGE"];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                [imgArray addObject:data];    
            }
            else if ( [[dict objectForKey:@"TYPE"] isEqualToString:@"TEXT"] )
            {
                NSString *order = [NSString stringWithFormat:@"%d", i];
                [reqDict setValue:order forKey:@"bodyTextOrder"];
            }
        }
        
        [reqDict setValue:imgArray forKey:@"images"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewPost" object:reqDict];
    }
    else 
    {
        // modify
        
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        
        for ( int i = 0; i < [tableData count]; i++ )
        {
            NSMutableDictionary *dict = [tableData objectAtIndex:i];
            
            if ( modifyInfoDict != nil )
            {
                NSString *attachmentID = [dict objectForKey:@"ID"];
                if ( attachmentID != nil && [@"" isEqualToString:attachmentID] == NO )
                {
                    NSMutableArray *modifyArray = [modifyInfoDict objectForKey:@"MODIFY"];
                    if ( modifyArray == nil )
                    {
                        modifyArray = [[NSMutableArray alloc] init];
                        [modifyInfoDict setValue:modifyArray forKey:@"MODIFY"];
                        [modifyArray release];
                    }
                    
                    [modifyArray addObject:[NSString stringWithFormat:@"%@:%d", attachmentID, i]];
                }
                else {
                    
                    if ( [[dict objectForKey:@"TYPE"] isEqualToString:@"IMAGE"] )
                    {
                        UIImage *image = [dict objectForKey:@"IMAGE"];
                        NSData *data = UIImageJPEGRepresentation(image, 1.0);
                        [imgArray addObject:data];    
                    }
                    
                    NSMutableArray *newArray = [modifyInfoDict objectForKey:@"NEW"];
                    if ( newArray == nil )
                    {
                        newArray = [[NSMutableArray alloc] init];
                        [modifyInfoDict setValue:newArray forKey:@"NEW"];
                        [newArray release];
                    }
                    
                    [newArray addObject:[NSString stringWithFormat:@"%d", i]];
                }
            }
        }
        
        [modifyInfoDict setValue:imgArray forKey:@"images"];
        [modifyInfoDict setValue:postTitleField.text forKey:@"subject"];
        [modifyInfoDict setValue:inputTextView.text forKey:@"content"];
        [modifyInfoDict setValue:selectedCategoryID forKey:@"categoryID"];
        [modifyInfoDict setValue:boardName forKey:@"boardName"];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:modifyInfoDict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ModifyPost" object:dict];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.inputTextView = nil;
    self.postTitle = nil;
    self.content = nil;
    self.tableData = nil;
    self.boardName = nil;
//    self.boardCategoryList = nil;
    self.selectedCategoryID = nil;
    self.selectedCategoryName = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    [postTitleField release];
    [inputTextView release];
    [postTitle release];
    [content release];
    [customToolBar release];
    [optionView release];
    [tableData release];
    [categoryLabel release];
    [pictureInfoView release];
    [pictureNumberLabel release];
    [picturesTableView release];
    [modifyInfoDict release];
    [boardName release];
//    [boardCategoryList release];
    [selectedCategoryID release];
    [selectedCategoryName release];
    
    [super dealloc];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissOptionView];
    [self dismissPicturesTableView];
    
    pictureNumberLabel.text = [NSString stringWithFormat:@"사진 %d", [tableData count] - 1];
    
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [textView.text isEqualToString:@"내용"] )
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];   
    }
    
    [self dismissOptionView];
    [self dismissPicturesTableView];
    
    pictureNumberLabel.text = [NSString stringWithFormat:@"사진 %d", [tableData count] - 1];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"내용";
        [textView resignFirstResponder];
    }
}

-(void) presentOptionView
{
    if ( optionView == nil )
    {
        optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 423, 320, 263)];
        
        [self.view addSubview:optionView];
        
        UIButton *btnTakePicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnTakePicture.frame = CGRectMake(10, 10, 300, 40);
        [btnTakePicture setTitle:@"사진찍기" forState:UIControlStateNormal];
        [btnTakePicture addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [optionView addSubview:btnTakePicture];
        
        UIButton *btnLoadFromAlbums = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnLoadFromAlbums.frame = CGRectMake(10, 60, 300, 40);
        [btnLoadFromAlbums setTitle:@"앨범에서 불러오기" forState:UIControlStateNormal];
        [btnLoadFromAlbums addTarget:self action:@selector(loadImageFromAlbum) forControlEvents:UIControlEventTouchUpInside];
        [optionView addSubview:btnLoadFromAlbums];
    }
    else {
        optionView.frame = CGRectMake(0, 423, 320, 263);
    }
    
    if ( [DYViewController isRetinaDisplay] )
    {
        optionView.frame = CGRectMake(optionView.frame.origin.x, optionView.frame.origin.y + 90 ,
                                      optionView.frame.size.width, optionView.frame.size.height);
    }
    
    optionView.backgroundColor = [UIColor colorWithHexString:@"#D3D1D2"];
    
    // delay and move view out of superview
    CGRect optionsFrame = optionView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    optionsFrame.origin.y -= optionsFrame.size.height;
    optionView.frame = optionsFrame;
    
    [UIView commitAnimations];
}

-(void) dismissOptionView
{
    CGRect optionsFrame = optionView.frame;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    optionsFrame.origin.y += optionsFrame.size.height;
    optionView.frame = optionsFrame;
    
    [UIView commitAnimations];

}

-(void) getImage
{
    [postTitleField resignFirstResponder];
    [inputTextView resignFirstResponder];

    [self presentOptionView];
}

-(void) takePicture
{
    UIImagePickerController* imagePickerController;
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController presentModalViewController:imagePickerController animated:YES];
}

-(void) loadImageFromAlbum
{
    UIImagePickerController* imagePickerController;
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentModalViewController:imagePickerController animated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    
    if ( image == nil )
        NSLog(@"nil");
    else
    {
        int width = (image.size.width >= image.size.height)? 1024:768;
        float ratio = image.size.height / image.size.width;
        
        int height = ( ratio * width);

        if ( width < image.size.width )
        {
            image = [self imageWithImage:image scaledToSize:CGSizeMake(width, height)];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:@"IMAGE" forKey:@"TYPE"];
        [dict setValue:image forKey:@"IMAGE"];
        
        [tableData addObject:dict];
        [dict release];
 
        pictureNumberLabel.text = [NSString stringWithFormat:@"사진 %d", [tableData count] - 1];
        pictureInfoView.hidden = NO;
    }
    
    [inputTextView becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    [inputTextView becomeFirstResponder];
}

-(void) presentPicturesTableView
{
    if ( picturesTableView == nil )
    {
        picturesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 423, 320, 262) 
                                                         style:UITableViewStylePlain];
        picturesTableView.delegate = self;
        picturesTableView.dataSource = self;
        [self.view addSubview:picturesTableView];
    }
    else {
        picturesTableView.frame = CGRectMake(0, 423, 320, 262);
    }
    
    if ( [DYViewController isRetinaDisplay] )
    {
        picturesTableView.frame = CGRectMake(picturesTableView.frame.origin.x, picturesTableView.frame.origin.y + 90 ,
                                      picturesTableView.frame.size.width, picturesTableView.frame.size.height);
    }
    
    CGRect frame = picturesTableView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    frame.origin.y -= frame.size.height;
    picturesTableView.frame = frame;
    
    [UIView commitAnimations];
    
    [picturesTableView setEditing:YES];
    [picturesTableView reloadData];
}

-(void) dismissPicturesTableView
{
    CGRect frame = picturesTableView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    frame.origin.y += frame.size.height;
    picturesTableView.frame = frame;
    
    [UIView commitAnimations];
    
}

-(void) editPictures
{
    [postTitleField resignFirstResponder];
    [inputTextView resignFirstResponder];
    
    [self dismissOptionView];
    [self presentPicturesTableView];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    return 70;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UIImageView *imgView = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, 60, 60)];
        imgView.tag = 1;
        [cell addSubview:imgView];
        [imgView release]; 
    }
    
    NSMutableDictionary *dict = [tableData objectAtIndex:indexPath.row];
    
    if ( [@"TEXT" isEqualToString:[dict objectForKey:@"TYPE"]] )
    {
        cell.textLabel.text = inputTextView.text;
    }
    else if ( [@"IMAGE" isEqualToString:[dict objectForKey:@"TYPE"]] )
    {
        imgView = (UIImageView *) [cell viewWithTag:1];
        UIImage *image = [dict objectForKey:@"IMAGE"];
        imgView.image = [self imageWithImage:image scaledToSize:CGSizeMake(58, 58)];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        NSMutableDictionary *obj = [tableData objectAtIndex:indexPath.row];
        
        if ( [[obj objectForKey:@"TYPE"] isEqualToString:@"TEXT"] )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"본문내용은 삭제하실 수 없습니다." 
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];
            return;
        }
        
        if ( modifyInfoDict != nil )
        {
            NSString *attachmentID = [obj objectForKey:@"ID"];
            
            if ( attachmentID != nil && [@"" isEqualToString:attachmentID] == NO )
            {
                NSMutableArray *deleteArray = [modifyInfoDict objectForKey:@"DELETE"];
                if ( deleteArray == nil )
                {
                    deleteArray = [[NSMutableArray alloc] init];
                    [modifyInfoDict setValue:deleteArray forKey:@"DELETE"];
                    [deleteArray release];
                }
                
                [deleteArray addObject:attachmentID];
            }
        }
        
        [tableData removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    NSUInteger fromRow = [fromIndexPath row];
    NSUInteger toRow = [toIndexPath row];
    
    id object = [[tableData objectAtIndex:fromRow] retain];
    [tableData removeObjectAtIndex:fromRow];
    [tableData insertObject:object atIndex:toRow];
    [object release];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end
