//
//  TTDBManager.h
//  GLDBManager
//
//  Created by guanglong on 16/7/18.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDBProtocol.h"

@interface TTDBManager : NSObject

+ (instancetype)shareInstance;

- (BOOL)insertData:(id<TTDBProtocol>)data;
- (BOOL)insertDatas:(NSArray<id<TTDBProtocol>>*)datas;

// condition 不用必须以 where开头
- (BOOL)deleteFromTable:(NSString*)tableName where:(NSString *)condition;
- (BOOL)deleteFromDataClass:(Class)dataClass where:(NSString *)condition;
- (BOOL)deleteFromData:(id<TTDBProtocol>)data where:(NSString *)condition;

- (BOOL)updateInTable:(NSString*)tableName withUpdateInfo:(id)updateInfo where:(NSString*)condition;
- (BOOL)updateInDataClass:(Class)dataClass withUpdateInfo:(id)updateInfo where:(NSString*)condition;
- (BOOL)updateInData:(id<TTDBProtocol>)data withUpdateInfo:(id)updateInfo where:(NSString*)condition;

// 如果 concernedColumns 为nil，则查询出所有字段的值
- (NSArray*)queryFromTable:(NSString*)tableName concernedColumns:(NSArray*)concernedColumns where:(NSString*)condition;
- (NSArray*)queryFromDataClass:(Class)dataClass concernedColumns:(NSArray *)concernedColumns where:(NSString *)condition;
- (NSArray*)queryFromTable:(NSString *)tableName where:(NSString *)condition;
- (NSArray*)queryFromDataClass:(Class)dataClass where:(NSString *)condition;


- (BOOL)tableExists:(NSString*)tableName;
- (NSArray*)queryWithSql:(NSString*)querySql;
- (BOOL)updateWithSql:(NSString*)updateSql;

@end
