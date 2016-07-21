//
//  Feed.h
//  GLDBManager
//
//  Created by guanglong on 16/7/18.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Rss, Info;

@interface Feed : NSObject

@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString* itemId;
@property (nonatomic, copy) NSString* title;

@property (nonatomic, strong) Info* infooo;
@property (nonatomic, strong) NSArray<Rss*>* rsses;

@end


@interface Rss : NSObject

@property (nonatomic, copy) NSString* rssId;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* content;

@end


@interface Info : NSObject

@property (nonatomic, assign) long long id;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSNumber* age;
@property (nonatomic, assign) float height;

@end
