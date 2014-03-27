//
//  ASLLogOptions.h
//  ASLLogger
//
//  Created by Chen Hai Teng on 3/27/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const optASLMessageFormat;
extern NSString * const optASLTimeFormat;
extern NSString * const optASLFilterMask;
extern NSString * const optASLTextEncoding;

@interface ASLLogOptions : NSObject
@property (strong) NSString * messageFormat;
@property (strong) NSString * timeFormat;
@property (assign) int filters;
@property (assign) int textEncoding;

+ (ASLLogOptions *)optionsWithMessageFormat:(NSString *)msgFmt;
+ (ASLLogOptions *)optionsFromDictionary:(NSDictionary *)dict;
- (id)initWithMessageFormat:(NSString *)msgFmt;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
