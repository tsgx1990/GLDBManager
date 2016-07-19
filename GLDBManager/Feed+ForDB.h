//
//  Feed+ForDB.h
//  GLDBManager
//
//  Created by guanglong on 16/7/19.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "Feed.h"
#import "TTDBProtocol.h"

@interface Feed (ForDB)<TTDBProtocol>

@end

@interface Rss (ForDB)<TTDBProtocol>

@end


@interface Info (ForDB)<TTDBProtocol>

@end