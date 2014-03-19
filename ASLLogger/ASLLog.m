//
//  ASLLog.m
//  ASLLogger
//
//  Created by Chen Hai Teng on 3/19/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import "ASLLog.h"
#import <asl.h>

@interface ASLLog()
@property (nonatomic, assign) aslclient client;
@property (nonatomic, retain) NSMutableDictionary * logFiles;
@end



static inline void asllog(ASLLog* logger, int level, NSString * format, va_list args)
{
    asl_log(logger.client, NULL, level, "%s", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

@implementation ASLLog

static ASLLog * defaultLog;

+ (ASLLog *)defaultLog
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLog = [[ASLLog alloc] initWithIdent:nil];
    });
    return defaultLog;
}

+ (ASLLog *)logWithIdent:(NSString *)ident
{
    if (ident && [ident length] != 0) {
        return [[ASLLog alloc] initWithIdent:ident];
    }
    return [ASLLog defaultLog];
}

- (id)initWithIdent:(NSString *)ident
{
    self = [super init];
    if (self) {
        if (ident && [ident length] != 0) {
            _client = asl_open([ident UTF8String], "", ASL_OPT_NO_DELAY|ASL_OPT_STDERR);
        } else {
            _client = NULL;
            asl_add_log_file(_client, STDERR_FILENO);
        }
        _logFiles = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addLogFileInternal:(NSString *)path
{
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle seekToEndOfFile];
    int fd = [handle fileDescriptor];
    asl_add_log_file(self.client, fd);
    [self.logFiles setObject:handle forKey:path];
}

- (void)addLogFile:(NSString *)path
{
    NSFileHandle * handle = [self.logFiles objectForKey:path];
    //check if the file is already added
    if (!handle) {
        BOOL isDir = NO;
        if (NO == [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || isDir == YES) {
            if (NO == [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
                [self debug:@"Cannot create log file"];
                return;
            }
        }
        [self addLogFileInternal:path];
    }
}

- (void)removeLogFile:(NSString *)path
{
    NSFileHandle* handle = [self.logFiles objectForKey:path];
    //check if the file is already added
    if (handle) {
        asl_remove_log_file(self.client, [handle fileDescriptor]);
        [handle closeFile];
        [self.logFiles removeObjectForKey:path];
    }
}

- (void)logWith:(int)level format:(NSString *)format arguments:(va_list)args
{
    asl_log(self.client, NULL, level, "%s", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}


- (void)emergency:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_EMERG, format, args);
    va_end(args);
}

- (void)alert:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_ALERT, format, args);
    va_end(args);
}

- (void)critical:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_CRIT, format, args);
    va_end(args);
}

- (void)error:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_ERR, format, args);
    va_end(args);
}

- (void)warning:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_WARNING, format, args);
    va_end(args);
}

- (void)notice:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_NOTICE, format, args);
    va_end(args);
}

- (void)info:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_INFO, format, args);
    va_end(args);
}

- (void)debug:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    asllog(self, ASL_LEVEL_DEBUG, format, args);
    va_end(args);
}

- (void)dealloc
{
    if (_client != NULL) {
        asl_close(_client);
    }
    if ([_logFiles count]) {
        [_logFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFileHandle * handle = obj;
            [handle closeFile];
        }];
        _logFiles = nil;
    }
}
@end
