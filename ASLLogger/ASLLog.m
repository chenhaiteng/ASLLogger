//
//  ASLLog.m
//  ASLLogger
//
//  Created by Chen Hai Teng on 3/19/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import "ASLLog.h"
#import "ASLLogOptions.h"

@interface ASLLog()
@property (nonatomic, strong) NSMutableDictionary * logFiles;
- (BOOL)checkFileExist:(NSString *)path;
- (BOOL)createLogFile:(NSString *)path;
@end

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

- (BOOL)checkFileExist:(NSString *)path
{
    BOOL result = NO;
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir == NO) {
        result = YES;
    }
    return result;
}

- (BOOL)createLogFile:(NSString *)path
{
    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
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
        if (NO == [self checkFileExist:path]) {
            if( NO == [self createLogFile:path]) {
                [self warning:@"Cannot create log file."];
                return;
            }
        }
        [self addLogFileInternal:path];
    }
}

- (void)addLogFileInternal:(NSString *)path withOptions:(ASLLogOptions *)options
{
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle seekToEndOfFile];
    int fd = [handle fileDescriptor];
    asl_add_output_file(self.client, fd, [options.messageFormat UTF8String], [options.timeFormat UTF8String], options.filters, options.textEncoding);
    [self.logFiles setObject:handle forKey:path];
}

- (void)addLogFile:(NSString *)path withOptions:(ASLLogOptions *)options;
{
    
    NSFileHandle * handle = [self.logFiles objectForKey:path];
    //check if the file is already added
    if (!handle) {
        if (NO == [self checkFileExist:path]) {
            if (NO == [self createLogFile:path]) {
                [self warning:@"Cannot create log file."];
                return;
            }
        }
    }
    [self addLogFileInternal:path withOptions:options];
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

/* refer to rsms's asl-logging project
 * https://github.com/rsms/asl-logging/blob/master/objc/ASLLogger.m
 */
#define LOGFUNC(NAME, LEVEL) \
- (void)NAME:(NSString *)format, ...\
{\
    va_list args;\
    va_start(args, format);\
    asl_log(self.client, NULL, LEVEL, "%s", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);\
    va_end(args);\
}

LOGFUNC(emergency, ASL_LEVEL_EMERG)
LOGFUNC(alert, ASL_LEVEL_ALERT)
LOGFUNC(critical, ASL_LEVEL_CRIT)
LOGFUNC(error, ASL_LEVEL_ERR)
LOGFUNC(warning, ASL_LEVEL_WARNING)
LOGFUNC(notice, ASL_LEVEL_NOTICE)
LOGFUNC(info, ASL_LEVEL_INFO)
LOGFUNC(debug, ASL_LEVEL_DEBUG)
#undef LOGFUNC

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
