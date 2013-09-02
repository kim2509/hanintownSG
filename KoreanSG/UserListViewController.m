//
//  UserListViewController.m
//  KoreanSG
//
//  Created by Daeyong Kim on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

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

@implementation UserListViewController

@synthesize tableData,originalTableData;

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
    
    self.title = @"받을 사람 선택";
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 420) style:UITableViewStylePlain];
    
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
    [myTableView release];
    
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    searchBar.barStyle=UIBarStyleDefault;
    searchBar.showsCancelButton=NO;
    searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.delegate = self;
    
    myTableView.tableHeaderView = searchBar;
    [searchBar release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

-(void) viewWillAppear:(BOOL)animated
{
    @try {
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(getUserListSent:) name:@"GetUserListSent" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(getUserListReceived:) name:@"GetUserListReceived" object:nil];
        
        [[TransactionManager sharedManager] getUserList];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@", exception);
    }
    @finally {
        
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) getUserListSent:(NSNotification *)notification
{
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
          :UIActivityIndicatorViewStyleGray];
	av.frame=CGRectMake(130, 180, 50, 50);
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];
}

-(NSMutableArray *) getTableDataWithUsers:(NSMutableArray *) data
{
    //메모리할당
	NSMutableArray *indexedData = [[[NSMutableArray alloc] init] autorelease];
	//인덱스 배열 초기화 (ㄱ~ㅎ)
	index = [[NSArray alloc] initWithObjects:@"A", @"F", @"K", @"P",
             @"ㄱ", @"ㄴ", @"ㄷ", @"ㄹ", @"ㅁ", @"ㅂ", @"ㅅ", @"ㅇ", @"ㅈ", @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ", nil];
	
    //NSMutableArray배열을 생성 - 14개
	NSMutableArray *tempNickname[[index count]];
	//위에서 만든 NSMutableArray의 초기사이즈를 100으로 설정
	for(int i = 0; i < [index count]; i++)
	{
		tempNickname[i] = [NSMutableArray arrayWithCapacity:100];
	}
    
	NSArray *name = data;
	//인덱스에 있는 한글 자음들과 데이터에 있는 이름들의 첫 글자를 비교해 동일한 글자이면 temp[index번째]에 이름을 지정
	for(int i = 0; i < [index count]; i++)
	{
		NSString *firstName = [index objectAtIndex:i];
		for(int j = 0; j < [name count]; j++)
		{
			NSString *str = [NSString stringWithFormat:@"%@(%@)",[[name objectAtIndex:j] objectForKey:@"NICKNAME"],
                             [[name objectAtIndex:j] objectForKey:@"USER_ID"]];
			//퍼스트네임과 셀프서브트랙트가 같은지 비교
			if([firstName isEqualToString:[self subtract:[str uppercaseString]]]) //subtract : 문자를 주면 첫글자 자음을 리턴
			{
				[tempNickname[i] addObject:str];
			}
		}
	}
	//데이터가 있는 것만 추출해서 section_name이라는 키로 한글 자음을 저장하고
	//data라는 키로 이름배열을 저장해서 딕셔너리를 생성한 후 이 딕셔너리들을 sectionData에 추가
	for(int i = 0; i < [index count]; i++)
	{
		//출력된 결과의 자음-모음 순 정렬, 없으면 강씨와 김씨가 뒤죽박죽임
		tempNickname[i] = (NSMutableArray *)[tempNickname[i] sortedArrayUsingSelector:@selector(compare:)];
        
		if([tempNickname[i] count] != 0) // = 데이터가 있으면
		{
			NSDictionary *Dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [index objectAtIndex:i], @"section_name", tempNickname[i], @"data", nil];
			[indexedData addObject:Dic];
		}
	}
    
    return indexedData;
}

-(void) getUserListReceived:(NSNotification *)notification
{
    @try {
        
        [av removeFromSuperview];
        
        NSMutableDictionary *resDict = ( NSMutableDictionary * ) notification.object;
        
        NSLog(@"Response:%@", resDict );
        
        if ([ErrCodeSuccess isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            self.tableData = [self getTableDataWithUsers:[resDict objectForKey:@"resultBody"]];
            self.originalTableData = [self getTableDataWithUsers:[resDict objectForKey:@"resultBody"]];
            [myTableView reloadData];
        }
        else if ([ErrCodeFail isEqualToString:[resDict objectForKey:@"resCode"]] )
        {
            
            NSString *errMsg = [NSString stringWithFormat:@"서버와의 통신이 원활하지 않습니다.\n잠시 후 다시 시도해 주십시오.(%@)", 
                                [resDict objectForKey:@"resCode"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];            
        }
        else {
            
            NSString *errMsg = [NSString stringWithFormat:@"%@(%@)", [resDict objectForKey:@"resMsg"],
                                [resDict objectForKey:@"resCode"]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            [alert autorelease];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[httpRequestReceived exception]: %@", exception);
    }
    @finally {
        
    }
}


//문자열을 매개변수로 받아서 첫글자의 한글 자음을 리턴해주는 메서드
- (NSString *)subtract:(NSString*)temp
{
	//영문은 이렇게 비교할 필요가 없다.
	NSComparisonResult 
    
    result = [temp compare:@"F"]; 
	if(result == NSOrderedAscending) 
		return @"A";
    
    result = [temp compare:@"K"]; 
	if(result == NSOrderedAscending) 
		return @"F";
    
    result = [temp compare:@"P"]; 
	if(result == NSOrderedAscending) 
		return @"K";
    
    result = [temp compare:@"가"]; 
	if(result == NSOrderedAscending) 
		return @"P";

	result = [temp compare:@"나"]; //한글 중에 ‘나’ 보다 작은 문자 
	if(result == NSOrderedAscending) 
		return @"ㄱ"; //ㄱ 으로
	
	result = [temp compare:@"다"]; //다 보다 작으면
	if(result == NSOrderedAscending) 
		return @"ㄴ"; //ㄴ 으로~
	
	result = [temp compare:@"라"];
	if(result == NSOrderedAscending) 
		return @"ㄷ";
	result = [temp compare:@"마"];
	if(result == NSOrderedAscending) 
		return @"ㄹ";
	result = [temp compare:@"바"];
	if(result == NSOrderedAscending) 
		return @"ㅁ";
	result = [temp compare:@"사"];
	if(result == NSOrderedAscending) 
		return @"ㅂ";
	result = [temp compare:@"아"];
	if(result == NSOrderedAscending) 
		return @"ㅅ";
	result = [temp compare:@"자"];
	if(result == NSOrderedAscending) 
		return @"ㅇ";
	result = [temp compare:@"차"];
	if(result == NSOrderedAscending) 
		return @"ㅈ";
	result = [temp compare:@"카"];
	if(result == NSOrderedAscending) 
		return @"ㅊ";
	result = [temp compare:@"타"];
	if(result == NSOrderedAscending) 
		return @"ㅋ";
	result = [temp compare:@"파"];
	if(result == NSOrderedAscending) 
		return @"ㅌ";
	result = [temp compare:@"하"];
	if(result == NSOrderedAscending) 
		return @"ㅍ";
	return @"ㅎ";
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [tableData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDictionary *Dic = [tableData objectAtIndex:section];
	//데이터키에 해당하는 것을 찾아서 ar로 리턴
    NSMutableArray *ar = [Dic objectForKey:@"data"];
    return [ar count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if ( bSearching ) return nil;
    
    NSMutableArray *ar = [[[NSMutableArray alloc] init] autorelease];
    
    for ( int i = 0;i < [tableData count]; i++ )
    {
        NSDictionary *dict = [tableData objectAtIndex:i];
        [ar addObject:[dict objectForKey:@"section_name"]];
    }
    
    return ar;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index2 {
    
    return index2;
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    //섹션데이터에 가서 섹션넘버에 해당하는것을 가져옴
	NSDictionary *Dic = [tableData objectAtIndex:section];
	//섹션_네임 에 해당하는것을 가져옴(ㄱ,ㄴ,ㄷ..등 해당되는 것만)
	NSString *sectionName = [Dic objectForKey:@"section_name"];
    
    if ( [@"A" isEqualToString:sectionName] )
        return @"A-E";
    else if ( [@"F" isEqualToString:sectionName] )
        return @"F-J";
    else if ( [@"K" isEqualToString:sectionName] )
        return @"K-Z";
    
	return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    NSDictionary *Dic = [tableData objectAtIndex:indexPath.section]; 
	NSMutableArray *ar = [Dic objectForKey:@"data"];
	cell.textLabel.text = [ar objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *Dic = [tableData objectAtIndex:indexPath.section]; 
	NSMutableArray *ar = [Dic objectForKey:@"data"];
	NSString *selectedItem = [ar objectAtIndex:indexPath.row];
    
    NSString *nickName = [[selectedItem componentsSeparatedByString:@"("] objectAtIndex:0];
    NSString *userID = [[selectedItem componentsSeparatedByString:@"("] objectAtIndex:1];
    userID = [userID stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    NSMutableDictionary *reqDict = [[[NSMutableDictionary alloc] init] autorelease];
    [reqDict setValue:userID forKey:@"selectedUserID"];
    [reqDict setValue:nickName forKey:@"selectedUserNickname"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserSelected" object:reqDict];
    
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UISearchbar delegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar2
{
	// only show the status bar’s cancel button while in edit mode
	searchBar2.showsCancelButton = YES;
	searchBar2.autocorrectionType = UITextAutocorrectionTypeNo;	
    bSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar2
{
	searchBar2.showsCancelButton = NO;
    bSearching = NO;
}

- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText
{
    if ( searchText == nil || [searchText isEqualToString:@""] ) 
    {
        [tableData removeAllObjects];
        [tableData addObjectsFromArray:self.originalTableData];
        [myTableView reloadData];
    }
    else
    {
        NSMutableArray *searchedData = [[[NSMutableArray alloc] init] autorelease];
        
        for ( int i = 0; i < [originalTableData count]; i++ )
        {
            NSDictionary *dict = [originalTableData objectAtIndex:i];
            
            NSString *sectionName = [dict objectForKey:@"section_name"];
            NSArray *data = [dict objectForKey:@"data"];
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            
            for ( int j = 0; j < [data count]; j++ )
            {
                NSString *userNickName = [data objectAtIndex:j];
                
                if ( [userNickName rangeOfString:searchText].length > 0 )
                {
                    [users addObject:userNickName];
                }
            }
            
            if ( [users count] > 0 )
            {
                [searchedData addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       sectionName, @"section_name", users, @"data", nil]];
            }
            
            [users release];
        }
          
        [tableData removeAllObjects];
        [tableData addObjectsFromArray:searchedData];
        [myTableView reloadData];
    }
}

- ( void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
    bSearching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar2
{
    searchBar.text = @"";
    [searchBar2 resignFirstResponder];
    bSearching = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar2
{
    [searchBar2 resignFirstResponder];
    bSearching = NO;
}

@end
