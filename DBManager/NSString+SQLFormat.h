//
//  NSString+SQLFormat.h
//  GLDBManager
//
//  Created by guanglong on 16/7/19.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (SQLFormat)


- (CGSize)sizeValue;

/**
 *  字符串格式化，如果参数为nil时，在格式化过程中显示为空字符串@""
 *
 *  @param format 可变参数列表
 *
 *  @return 格式化之后的字符串
 */
+ (NSString*)emptyStringWithFormat:(NSString*)format, ...;

/**
 *  字符串格式化
 *
 *  @param emptyString 如果参数为nil时，在格式化过程中需要显示的字符串。如果传nil，则在格式化字符串中显示为(null)。
 *  @param format      可变参数列表
 *
 *  @return 格式化之后的字符串
 */
+ (NSString*)emptyString:(NSString*)emptyString withFormat:(NSString*)format, ...;

/**
 *  格式化字符串的辅助函数
 *
 *  @param formatString 可变参数列表的第一个参数
 *  @param args         指向可变参数列表的指针
 *  @param emptyString  如果参数为nil时，在格式化过程中需要显示的字符串。如果传nil，则在格式化字符串中显示为(null)。
 *
 *  @return 格式化之后的字符串
 */
+ (NSMutableString*)handleFormatString:(NSString*)formatString argumentsList:(va_list)args emptyString:(NSString*)emptyString;


@end
