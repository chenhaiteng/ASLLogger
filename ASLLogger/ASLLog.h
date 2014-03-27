//
//  ASLLog.h
//  ASLLogger
//
//  Created by Chen Hai Teng on 3/19/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <asl.h>
#import "ASLLogOptions.h"

@interface ASLLog : NSObject
@property (nonatomic, readonly, assign) aslclient client;
+ (ASLLog *)defaultLog;
+ (ASLLog *)logWithIdent:(NSString *)ident;
- (void)addLogFile:(NSString *)path;
- (void)removeLogFile:(NSString *)path;
//- (void)addLogFile:(NSString *)path withOptions:(NSDictionary*)options;
- (void)addLogFile:(NSString *)path withOptions:(ASLLogOptions *)options;
#pragma mark Log to specified level
- (void)emergency:(NSString *)format, ...;  //ASL_LEVEL_EMERG   0
- (void)alert:(NSString *)format, ...;      //ASL_LEVEL_ALERT   1
- (void)critical:(NSString *)format, ...;   //ASL_LEVEL_CRIT    2
- (void)error:(NSString *)format, ...;      //ASL_LEVEL_ERR     3
- (void)warning:(NSString *)format, ...;    //ASL_LEVEL_WARNING 4
- (void)notice:(NSString *)format, ...;     //ASL_LEVEL_NOTICE  5
- (void)info:(NSString *)format, ...;       //ASL_LEVEL_INFO    6
- (void)debug:(NSString *)format, ...;      //ASL_LEVEL_DEBUG   7
@end
