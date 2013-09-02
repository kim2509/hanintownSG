
#import "Constants.h"

@implementation Constants

+(NSString *) getClientVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+(NSString *) metaInfoURL
{
    return [NSString stringWithFormat:@"%@/%@",
                ServerUrl, @"iphone/metaInfoJson2.php"];
}

+(NSString *) userLikesNCommentsURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/getUserLikesNComments.php"];
}

+(NSString *) getAllServiceMenu
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/getAllServiceMenu.php"];
}

+(NSString *) mainInfo
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/getMainInfo.php"];
}

#pragma mark USER related URLs

+(NSString *) registerMemberURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/registerMember.php"];
}

+(NSString *) loginURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/login.php"];
}

+(NSString *) logoutURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/logout.php"];
}

+(NSString *) sendMessageURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/sendMessage.php"];
}

+(NSString *) messageListURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/messageList.php"];
}

+(NSString *) messageContentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/messageContent.php"];
}

+(NSString *) userListURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/userList.php"];
}

+(NSString *) notificationListURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/notificationList.php"];
}

#pragma mark BOARD related URLs

+(NSString *) boardMainInfo
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/getBoardMainInfo.php"];
}

+(NSString *) boardCategoryURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/getBoardCategory.php"];
}

+(NSString *) boardItemListURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/BoardItemList.php"];
}

+(NSString *) addBoardPostURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/addBoardPost.php"];    
}

+(NSString *) searchBoardURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/searchBoard.php"];    
}

+(NSString *) boardContentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/boardContent.php"];
}

+(NSString *) modifyBoardContentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/modifyBoardContent.php"];    
}

+(NSString *) addReplyURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/addReply.php"];
}

+(NSString *) deleteBoardContentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"web/mobile/board/deleteBoardContent.php"];    
}

#pragma mark SHOP related URLs

+(NSString *) addShopLikeURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/AddShopLike.php"];
}

+(NSString *) unlikeShopURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/UnlikeShop.php"];
}

+(NSString *) addShopCommentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/AddShopComment.php"];
}

+(NSString *) deleteShopComment
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/DeleteShopComment.php"];
}

+(NSString *) shopImageURL:(int) shopSeq
{
    return [[NSString stringWithFormat:@"%@/iphone/images/shop/S%d.png",
            ServerUrl, shopSeq] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *) uploadShopImageURL
{
    return [[NSString stringWithFormat:@"%@/iphone/uploadShopImage.php",
             ServerUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark MENU related URLs

+(NSString *) addMenuLikeURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/AddMenuLike.php"];
}

+(NSString *) unlikeMenuURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/UnlikeMenu.php"];
}

+(NSString *) addMenuCommentURL
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/AddMenuComment.php"];
}

+(NSString *) deleteMenuComment
{
    return [NSString stringWithFormat:@"%@/%@",
            ServerUrl, @"iphone/DeleteMenuComment.php"];
}

+(NSString *) menuImageURL:(int) menuSeq
{
    return [NSString stringWithFormat:@"%@/iphone/images/menu/M%d.png",
            ServerUrl, menuSeq];
}

+(NSString *) uploadMenuImageURL
{
    return [[NSString stringWithFormat:@"%@/iphone/uploadMenuImage.php",
             ServerUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end