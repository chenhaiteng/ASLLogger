//
//  ASLLogOptions.m
//  ASLLogger
//
//  Created by Chen Hai Teng on 3/27/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import "ASLLogOptions.h"
#import <asl.h>

NSString * const optASLMessageFormat    = @"ASLMessageFormat";
NSString * const optASLTimeFormat       = @"ASLTimeFormat";
NSString * const optASLFilterMask       = @"ASLFilterMask";
NSString * const optASLTextEncoding     = @"ASLTextEncoding";

@implementation ASLLogOptions
+ (ASLLogOptions *)optionsWithMessageFormat:(NSString *)msgFmt
{
    return [[ASLLogOptions alloc] initWithMessageFormat:msgFmt];
}

+ (ASLLogOptions *)optionsFromDictionary:(NSDictionary *)dict
{
    return [[ASLLogOptions alloc] initWithDictionary:dict];
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class ASLLogOptions"
                                 userInfo:nil];
    return nil;
}

- (id)initWithMessageFormat:(NSString *)msgFmt
{
    self = [super init];
    if (self) {
        _messageFormat = msgFmt;
        if (nil == _messageFormat) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Needs optASLMessageFormat to create ASLLogOptions."
                                         userInfo:nil];
            self = nil;
        } else {
            _timeFormat = [NSString stringWithUTF8String:ASL_TIME_FMT_LCL];
            _filters = ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG);
            _textEncoding = ASL_ENCODE_SAFE;
        }
    }
    return self;
}

- (void)cleanOptions
{
    _messageFormat = nil;
    _timeFormat = nil;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if (nil == dict) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Options dictionary should not be nil."
                                         userInfo:nil];
            self = nil;
        } else {
            _messageFormat = [dict objectForKey:optASLMessageFormat];
            if (nil == _messageFormat) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:@"Needs optASLMessageFormat to create ASLLogOptions."
                                             userInfo:nil];
                self = nil;
            } else {
                _timeFormat = [dict objectForKey:optASLTimeFormat];
                _filters = [[dict objectForKey:optASLFilterMask] intValue];
                _textEncoding = [[dict objectForKey:optASLTextEncoding] intValue];
                if ([_timeFormat isEqualToString:[NSString stringWithUTF8String:ASL_TIME_FMT_LCL]] || [_timeFormat isEqualToString:[NSString stringWithUTF8String:ASL_TIME_FMT_UTC]] || [_timeFormat isEqualToString:[NSString stringWithUTF8String:ASL_TIME_FMT_SEC]]) {
                    if ( 0 == _filters) {
                        _filters = ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG);
                    }
                } else {
                    [self cleanOptions];
                    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                                   reason:@"Needs optASLMessageFormat to create ASLLogOptions."
                                                 userInfo:nil];
                    self = nil;
                }
            }
        }
    }
    return self;
}
@end
