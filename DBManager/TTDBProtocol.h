//
//  TTDBProtocol.h
//  DBManager
//
//  Created by guanglong on 16/7/18.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+SQLFormat.h"

#define kDBForeignKey     @"_key__foreign_db__xxtt_"

@protocol TTDBProtocol <NSObject>

@required
+ (NSArray*)concernedColumns; // 需要存储的字段

+ (NSArray*)conformDBProtocolColumns; // 遵循TTDBProtocol的字段，包括数组属性

+ (Class)innerClassForPropertyName:(NSString*)propertyName;

- (NSString*)sqlCreatingTable; // 创建表的sql
- (NSString*)sqlInsertingData; // 插入数据的sql


@optional

// 涉及到外键，由subModel实现
- (NSString*)sqlInsertingDataWithSuperModel:(id<TTDBProtocol>)superModel;

// 由superModel实现
+ (NSString*)keyAsSubtableForeignKey;

@end
