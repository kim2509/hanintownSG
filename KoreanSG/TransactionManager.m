//
//  TransactionOperationManager.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 11. 2..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TransactionManager.h"
#import "Shop.h"
#import "Menu.h"

static TransactionManager *TransactionManagerInstance;

@implementation TransactionManager

@synthesize queue;

+(TransactionManager *) sharedManager
{
	@synchronized(self)
    {
		if (TransactionManagerInstance == NULL)
		{
			TransactionManagerInstance = [[TransactionManager alloc] init];
            
            if ( TransactionManagerInstance.queue == nil )
            {
                TransactionManagerInstance.queue = [[NSOperationQueue alloc] init];
            }
		}
    }	
	
	return TransactionManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(sendMessage:) name:@"SendMessage" object:nil];
        
    }
    return self;
}

-(void) setCommonHeader:(NSMutableDictionary *)reqDict
{
    [reqDict retain];
    
    DataManager *dataManager = [DataManager sharedDataManager];
    
    [reqDict setObject:[dataManager metaInfoString:@"USER_NO"] forKey:@"userNo"];
    [reqDict setObject:[dataManager metaInfoString:@"USER_ID"] forKey:@"userID"];
    [reqDict setObject:[dataManager metaInfoString:@"USER_DEVICE_TOKEN"] forKey:@"userDeviceToken"];
    [reqDict setObject:[dataManager metaInfoString:@"NICKNAME"] forKey:@"nickName"];
    [reqDict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"iOSVersion"];
    [reqDict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    [reqDict setObject:[Constants getClientVersion] forKey:@"ClientVersion"];
    
    [reqDict release];
}

-(void) getMetaInfoFromServer
{
    NSURL *url = [NSURL URLWithString:[Constants metaInfoURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    DataManager *dataManager = [DataManager sharedDataManager];
    NSMutableDictionary *reqParam = [[NSMutableDictionary alloc] init];
    [self setCommonHeader:reqParam];
    [reqParam setObject:[dataManager metaInfoString:@"SHOP_INFO_LAST_MODIFIED_DATE"] forKey:@"shopInfoLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"MENU_INFO_LAST_MODIFIED_DATE"] forKey:@"menuInfoLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"NEW_SHOP_INFO_LAST_MODIFIED_DATE"] forKey:@"newShopInfoLastModifiedDate"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [reqParam release];
    
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        TransactionOperation *transOP = [[TransactionOperation alloc] init];
        
        [transOP setUpdateShopInfoData:[request responseString]];
        
        [[self queue] addOperation:transOP];
        
        [transOP release];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        [[TransactionManager sharedManager] getUserLikesNComments];
        
        NSLog(@"%@", error );
    }];
    
    [[self queue] addOperation:request];
}

-(void) getUserLikesNComments
{
    NSURL *url = [NSURL URLWithString:[Constants userLikesNCommentsURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    DataManager *dataManager = [DataManager sharedDataManager];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    [self setCommonHeader:reqParam];
    [reqParam setObject:[dataManager metaInfoString:@"SHOP_LIKE_LAST_MODIFIED_DATE"] forKey:@"shopLikeLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"SHOP_COMMENT_LAST_MODIFIED_DATE"] forKey:@"shopCommentLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"SHOP_COMMENT_LIKE_LAST_MODIFIED_DATE"] forKey:@"shopCommentLikeLastModifiedDate"];
    
    [reqParam setObject:[dataManager metaInfoString:@"MENU_LIKE_LAST_MODIFIED_DATE"] forKey:@"menuLikeLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"MENU_COMMENT_LAST_MODIFIED_DATE"] forKey:@"menuCommentLastModifiedDate"];
    [reqParam setObject:[dataManager metaInfoString:@"MENU_COMMENT_LIKE_LAST_MODIFIED_DATE"] forKey:@"menuCommentLikeLastModifiedDate"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        TransactionOperation *transOP = [[TransactionOperation alloc] init];
        NSLog(@"%@", [request responseString]);
        [transOP setUserLikesNComments:[request responseString]];
        [[self queue] addOperation:transOP];
        [transOP release];
        
    }];

    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
    }];
    
    [[self queue] addOperation:request];
}

-(void) getMainInfo
{
    NSURL *url = [NSURL URLWithString:[Constants mainInfo]];    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetMainInfoSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSDictionary* resDict = [[request responseString] JSONValue];
        
        [resultDict setValue:@"0000" forKey:@"resCode"];
        [resultDict setValue:@"SUCCESS" forKey:@"resMsg"];
        
        [resultDict setValue:resDict forKey:@"resultBody"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetMainInfoReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetMainInfoReceived" object:resultDict];
        
    }];
}

-(void)getAllServiceMenuWithLevel:(NSString *) level parentID:(NSString *) parentID
{
    NSURL *url = [NSURL URLWithString:[Constants getAllServiceMenu]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    [reqParam setValue:level forKey:@"level"];
    [reqParam setValue:parentID forKey:@"parentID"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllServiceMenuSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [[array objectAtIndex:1] objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        [resultDict setValue:level forKey:@"level"];
        
        [resultDict setValue:[array objectAtIndex:0] forKey:@"resultBody"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllServiceMenuReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [resultDict setValue:level forKey:@"level"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllServiceMenuReceived" object:resultDict];
        
    }];
}

-(void) registerMember:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants registerMemberURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];

    [reqParam setObject:[dict objectForKey:@"userID"] forKey:@"userID"];
    [reqParam setObject:[dict objectForKey:@"nickName"] forKey:@"nickName"];
    [reqParam setObject:[dict objectForKey:@"email"] forKey:@"email"];
    [reqParam setObject:[dict objectForKey:@"password"] forKey:@"password"];
    [reqParam setObject:[dict objectForKey:@"confirmPassword"] forKey:@"confirmPassword"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
    
    [request setCompletionBlock:^{
    
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        if ([@"0000" isEqualToString:[resultDict objectForKey:@"resCode"]]) {
            NSMutableDictionary *resultBody = [array objectAtIndex:1];
            [resultDict setValue:resultBody forKey:@"resultBody"];
        }        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
}

-(void)login:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants loginURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    [reqParam setValue:@"" forKey:@"userNo"];
    [reqParam setValue:[dict objectForKey:@"userID"] forKey:@"userID"];
    [reqParam setValue:[dict objectForKey:@"password"] forKey:@"password"];
    [reqParam setValue:[dict objectForKey:@"facebookID"] forKey:@"facebookID"];
    [reqParam setValue:[dict objectForKey:@"facebookURL"] forKey:@"facebookURL"];
    [reqParam setValue:[dict objectForKey:@"nickName"] forKey:@"nickName"];
    
    NSString *sendNotificationName = @"loginSent";
    NSString *receiveNotificationName = @"loginReceived";
    
    if ( [dict objectForKey:@"facebookID"] != nil &&
        [@"" isEqualToString:[dict objectForKey:@"facebookID"]] == NO )
    {
        sendNotificationName = @"facebookLoginSent";
        receiveNotificationName = @"facebookLoginReceived";
    }
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:sendNotificationName object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        if ([@"0000" isEqualToString:[resultDict objectForKey:@"resCode"]]) {
            NSMutableDictionary *resultBody = [array objectAtIndex:1];
            [resultDict setValue:resultBody forKey:@"resultBody"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:receiveNotificationName object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:receiveNotificationName object:resultDict];
        
    }];
}


-(void)logout:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants logoutURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    NSString *sendNotificationName = @"logoutSent";
    NSString *receiveNotificationName = @"logoutReceived";
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:sendNotificationName object:nil];
    
    [request setCompletionBlock:^{
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:receiveNotificationName object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:receiveNotificationName object:resultDict];
        
    }];
}

-(void) getBoardMainInfo
{
    NSURL *url = [NSURL URLWithString:[Constants boardMainInfo]];    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardMainInfoSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSDictionary* resDict = [[request responseString] JSONValue];
        
        [resultDict setValue:@"0000" forKey:@"resCode"];
        [resultDict setValue:@"SUCCESS" forKey:@"resMsg"];
        
        [resultDict setValue:resDict forKey:@"resultBody"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardMainInfoReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardMainInfoReceived" object:resultDict];
        
    }];
}

-(void)getBoardCategory:(NSString *) boardName showAllCategory:(BOOL) bShowAllCategory
{
    NSURL *url = [NSURL URLWithString:[Constants boardCategoryURL]];    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    [reqParam setValue:(bShowAllCategory)? @"":@"N" forKey:@"showAllCategory"];
    [reqParam setValue:boardName forKey:@"boardName"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardCategorySent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [[array objectAtIndex:1] objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [resultDict setValue:[array objectAtIndex:0] forKey:@"resultBody"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardCategoryReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetBoardCategoryReceived" object:resultDict];
        
    }];
}

-(void)addBoardPost:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants addBoardPostURL]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request addRequestHeader: @"Content-Type" value:@"multipart/form-data;"];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    
    DataManager *dataManager = [DataManager sharedDataManager];
    
    [request addPostValue:[dataManager metaInfoString:@"USER_NO"] forKey:@"userNo"];
    [request addPostValue:[dataManager metaInfoString:@"USER_ID"] forKey:@"userID"];
    [request addPostValue:[dataManager metaInfoString:@"USER_DEVICE_TOKEN"] forKey:@"userDeviceToken"];
    [request addPostValue:[dataManager metaInfoString:@"NICKNAME"] forKey:@"nickName"];
    [request addPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"iOSVersion"];
    [request addPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    [request addPostValue:[Constants getClientVersion] forKey:@"ClientVersion"];
    
    [request addPostValue:[dict objectForKey:@"subject"] forKey:@"subject"];
    [request addPostValue:[dict objectForKey:@"content"] forKey:@"content"];
    [request addPostValue:[dict objectForKey:@"bodyTextOrder"] forKey:@"bodyTextOrder"];
    [request addPostValue:[dict objectForKey:@"categoryID"] forKey:@"categoryID"];
    [request addPostValue:[dict objectForKey:@"boardName"] forKey:@"boardName"];
    
    NSArray *ar = [dict objectForKey:@"images"];
    for ( int i = 0; i < [ar count]; i++ )
        [request addData:[ar objectAtIndex:i] withFileName:[NSString stringWithFormat:@"img%d", i] 
          andContentType:@"image/jpeg" forKey:@"image[]"];
    
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
                
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
}

-(void)addReply:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants addReplyURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    
    [reqParam setObject:[dict objectForKey:@"bID"] forKey:@"bID"];
    [reqParam setObject:[dict objectForKey:@"content"] forKey:@"content"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
}

-(void)deleteBoardContent:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants deleteBoardContentURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];
    
    [reqParam setObject:[dict objectForKey:@"bID"] forKey:@"bID"];
    [reqParam setObject:[dict objectForKey:@"boardName"] forKey:@"boardName"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
}

-(void)modifyBoardContent:(NSDictionary *) dict
{
    NSURL *url = [NSURL URLWithString:[Constants modifyBoardContentURL]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addRequestHeader: @"Content-Type" value:@"multipart/form-data;"];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    
    DataManager *dataManager = [DataManager sharedDataManager];
    
    [request addPostValue:[dataManager metaInfoString:@"USER_NO"] forKey:@"userNo"];
    [request addPostValue:[dataManager metaInfoString:@"USER_ID"] forKey:@"userID"];
    [request addPostValue:[dataManager metaInfoString:@"USER_DEVICE_TOKEN"] forKey:@"userDeviceToken"];
    [request addPostValue:[dataManager metaInfoString:@"NICKNAME"] forKey:@"nickName"];
    [request addPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"iOSVersion"];
    [request addPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    [request addPostValue:[Constants getClientVersion] forKey:@"ClientVersion"];
    
    [request addPostValue:[dict objectForKey:@"bID"] forKey:@"bID"];
    [request addPostValue:[dict objectForKey:@"subject"] forKey:@"subject"];
    [request addPostValue:[dict objectForKey:@"content"] forKey:@"content"];
    [request addPostValue:[dict objectForKey:@"boardName"] forKey:@"boardName"];
    
    NSMutableDictionary *modifyInfo = [[NSMutableDictionary alloc] init];
    [modifyInfo setValue:[dict objectForKey:@"NEW"] forKey:@"NEW"];
    [modifyInfo setValue:[dict objectForKey:@"MODIFY"] forKey:@"MODIFY"];
    [modifyInfo setValue:[dict objectForKey:@"DELETE"] forKey:@"DELETE"];
    
    [request addPostValue:[dict objectForKey:@"categoryID"] forKey:@"categoryID"];    
    [request addPostValue:[modifyInfo JSONRepresentation] forKey:@"modifyInfo"];
    
    NSArray *ar = [dict objectForKey:@"images"];
    for ( int i = 0; i < [ar count]; i++ )
        [request addData:[ar objectAtIndex:i] withFileName:[NSString stringWithFormat:@"img%d", i] 
          andContentType:@"image/jpeg" forKey:@"image[]"];
    
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HttpRequestReceived" object:resultDict];
        
    }];
}

-(void) addNewShop:(Shop *)shop
{
    NSURL *url = [NSURL URLWithString:@"http://www.hanintownsg.com/iphone/addNewShop.php"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam addEntriesFromDictionary:[shop dictionaryValues]];
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"shopname:%@  result:%@", shop.shopName, response );
    }
}

-(void) addShopMenu:(Menu *)menu
{
    NSURL *url = [NSURL URLWithString:@"http://www.hanintownsg.com/iphone/addShopMenu.php"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];

    [reqParam addEntriesFromDictionary:[menu dictionaryValues]];
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"menuName:%@  result:%@", menu.menuName, response );
    }
}

-(void) addShopLike:(Shop *) shop shoplike:(ShopLike *)shopLike
{
    [shop retain];
    [shopLike retain];
    
    NSURL *url = [NSURL URLWithString:[Constants addShopLikeURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",shop.seq] forKey:@"shopNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[DataManager sharedDataManager] insertShopLike:shopLike];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] == NO )
        {
            [[DataManager sharedDataManager] deleteShopLikes:
             [NSString stringWithFormat:@"%d", shopLike.shopLikeNo]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMessage" 
                                                                object:[resDict objectForKey:@"resMsg"]];
        }
        else
        {
            NSArray *responseArray = [resDict objectForKey:@"shopInfo"];
            int shopLikeNo = [[responseArray objectAtIndex:0] intValue];
            shopLike.shopLikeNo = shopLikeNo;
            
            [[DataManager sharedDataManager] updateShopLike:shopLike];    
        }
        
        [shop release];
        [shopLike release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[DataManager sharedDataManager] deleteShopLikes:
         [NSString stringWithFormat:@"%d", shopLike.shopLikeNo]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [[self queue] addOperation:request];
}

-(void) addShopComment:(Shop *) shop shopComment:(ShopComment *)shopComment
{
    [shop retain];
    [shopComment retain];
    
    NSURL *url = [NSURL URLWithString:[Constants addShopCommentURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",shop.seq] forKey:@"shopNo"];
    [reqParam setObject:shopComment.comment forKey:@"comment"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        NSArray *responseArray = [[request responseString] JSONValue];
        
        int shopCommentNo = [[responseArray objectAtIndex:0] intValue];
        shopComment.shopCommentNo = shopCommentNo;
        
        [[DataManager sharedDataManager] updateShopComment:shopComment];
        
        [shop release];
        [shopComment release];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [shop release];
        [shopComment release];
    }];
    
    [[self queue] addOperation:request];
}

-(void) addMenuLike:(Menu *) menu shoplike:(MenuLike *)menuLike
{
    [menu retain];
    [menuLike retain];
    
    NSURL *url = [NSURL URLWithString:[Constants addMenuLikeURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",menu.menuSeq] forKey:@"menuNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[DataManager sharedDataManager] insertMenuLike:menuLike];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] == NO )
        {
            [[DataManager sharedDataManager] deleteMenuLikes:
             [NSString stringWithFormat:@"%d", menuLike.menuLikeNo]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMessage" 
                                                                object:[resDict objectForKey:@"resMsg"]];
        }
        else
        {
            NSArray *responseArray = [resDict objectForKey:@"menuInfo"];
            
            int menuLikeNo = [[responseArray objectAtIndex:0] intValue];
            menuLike.menuLikeNo = menuLikeNo;
            
            [[DataManager sharedDataManager] updateMenuLike:menuLike];  
        }

        [menu release];
        [menuLike release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[DataManager sharedDataManager] deleteMenuLikes:
         [NSString stringWithFormat:@"%d", menuLike.menuLikeNo]];
        
        [menu release];
        [menuLike release];
        
    }];
    
    [[self queue] addOperation:request];
}

-(void) addMenuComment:(Menu *) menu shopComment:(MenuComment *) menuComment
{
    [menu retain];
    [menuComment retain];
    
    NSURL *url = [NSURL URLWithString:[Constants addMenuCommentURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",menu.menuSeq] forKey:@"menuNo"];
    [reqParam setObject:menuComment.comment forKey:@"comment"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        NSArray *responseArray = [[request responseString] JSONValue];
        
        int menuCommentNo = [[responseArray objectAtIndex:0] intValue];
        menuComment.menuCommentNo = menuCommentNo;
        
        [[DataManager sharedDataManager] updateMenuComment:menuComment];
        
        [menu release];
        [menuComment release];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [menu release];
        [menuComment release];
    }];
    
    [[self queue] addOperation:request];
}

-(void) unLikeShop:(ShopLike *)shopLike
{
    [shopLike retain];
    
    NSURL *url = [NSURL URLWithString:[Constants unlikeShopURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",shopLike.shopNo] forKey:@"shopNo"];
    [reqParam setObject:[NSString stringWithFormat:@"%d",shopLike.shopLikeNo] forKey:@"shopLikeNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] == NO )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMessage" 
                                                                object:[resDict objectForKey:@"resMsg"]];
        }
        else
        {
            [[DataManager sharedDataManager] deleteShopLikes:
             [NSString stringWithFormat:@"%d", shopLike.shopLikeNo]];
        }
        
        [shopLike release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [[self queue] addOperation:request];
}

-(void) unLikeMenu:(MenuLike *)menuLike
{
    [menuLike retain];
    
    NSURL *url = [NSURL URLWithString:[Constants unlikeMenuURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",menuLike.menuNo] forKey:@"menuNo"];
    [reqParam setObject:[NSString stringWithFormat:@"%d",menuLike.menuLikeNo] forKey:@"menuLikeNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] == NO )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowMessage" 
                                                                object:[resDict objectForKey:@"resMsg"]];
        }
        else
        {
            [[DataManager sharedDataManager] deleteMenuLikes:
             [NSString stringWithFormat:@"%d", menuLike.menuLikeNo]];
        }
        
        [menuLike release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [[self queue] addOperation:request];
}

-(void) deleteShopComment:(ShopComment *)shopComment
{
    [shopComment retain];
    
    NSURL *url = [NSURL URLWithString:[Constants deleteShopComment]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",shopComment.shopCommentNo] forKey:@"shopCommentNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] )
        {
            [[DataManager sharedDataManager] deleteShopComments:
             [NSString stringWithFormat:@"%d", shopComment.shopCommentNo]];
        }
        
        [shopComment release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [[self queue] addOperation:request];
}


-(void) deleteMenuComment:(MenuComment *)menuComment
{
    [menuComment retain];
    
    NSURL *url = [NSURL URLWithString:[Constants deleteMenuComment]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];

    [self setCommonHeader:reqParam];
    [reqParam setObject:[NSString stringWithFormat:@"%d",menuComment.menuCommentNo] forKey:@"menuCommentNo"];
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        
        NSLog(@"%@", [[[request responseString] JSONValue] class] );
        
        NSDictionary *resDict = [[request responseString] JSONValue];
        
        NSLog(@"resCode: %@", [resDict objectForKey:@"resCode"]);
        NSLog(@"resMsg: %@", [resDict objectForKey:@"resMsg"]);
        
        if ( [[resDict objectForKey:@"resCode"] isEqualToString:@"0000"] )
        {
            [[DataManager sharedDataManager] deleteMenuComments:
             [NSString stringWithFormat:@"%d", menuComment.menuCommentNo]];
        }
        
        [menuComment release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        NSLog(@"%@", error );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLikesNCommentsUpdate" object:@"2"];
    }];
    
    [[self queue] addOperation:request];
}

-(void) sendMessage:(NSNotification *)notification
{
    NSLog(@"sendMessage called.[%@]", notification.object);
    
    NSMutableDictionary * dict = (NSMutableDictionary *) notification.object;
    
    NSURL *url = [NSURL URLWithString:[Constants sendMessageURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [self setCommonHeader:dict];
    
    NSString *jsonString = [dict JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [array objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived" object:resultDict];
        
    }];
}

-(void)getUserList
{
    NSURL *url = [NSURL URLWithString:[Constants userListURL]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSMutableDictionary *reqParam = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self setCommonHeader:reqParam];    
    
    NSString *jsonString = [reqParam JSONRepresentation];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request appendPostData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startAsynchronous];
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserListSent" object:nil];
    
    [request setCompletionBlock:^{
        
        NSMutableArray *array = (NSMutableArray *) [[request responseString] JSONValue];
        
        NSMutableDictionary *resultHeader = [[array objectAtIndex:1] objectAtIndex:0];
        [resultDict setValue:[resultHeader objectForKey:@"RES_CODE"] forKey:@"resCode"];
        [resultDict setValue:[resultHeader objectForKey:@"RES_MSG"] forKey:@"resMsg"];
        
        [resultDict setValue:[array objectAtIndex:0] forKey:@"resultBody"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserListReceived" object:resultDict];
        
    }];
    
    [request setFailedBlock:^{
        
        [resultDict setValue:@"9999" forKey:@"resCode"];
        [resultDict setValue:[request error] forKey:@"resMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserListReceived" object:resultDict];
        
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ( self.queue != nil )
    {
        [queue release];
        self.queue = nil;
    }
    
    [super dealloc];
}

@end
