//
//  ASLLoggerTests.m
//  ASLLoggerTests
//
//  Created by Chen Hai Teng on 3/18/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ASLLog.h"
#import "ASLLogOptions.h"

NSString * const TestIdent = @"UTest";
NSString * const TestLogFile = @"UTest.log";
NSString * const TestLogOutput = @"Hello! ASLLog";
NSString * const TestLogFormat = @"Hello! %@";
NSString * const TestOutputFormat = @"<%@>: Hello! ASLLog";

NSString * const TestIdentForFmt = @"UTestFmt";
NSString * const TestLogFileForFmt = @"UTestFmt.log";

NSString * const TestIdentForFilter = @"UTestFilter";
NSString * const TestLogFileForFilter = @"UTestFilter.log";

NSString * const TestMessageFormat = @"Test Format $(Time)";

@interface ASLLoggerTests : XCTestCase

@end

@implementation ASLLoggerTests
+ (void)setUp
{
    NSFileManager * dm = [NSFileManager defaultManager];
    NSError * err = nil;
    NSArray * TestItems = [dm contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&err];
    for (NSString* item in TestItems) {
        [dm removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:item] error:&err];
    }
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)checkLog:(NSString*)line forLevel:(NSString*)level
{
    NSString * expected = [NSString stringWithFormat:TestOutputFormat, level];
    NSRange range = [line rangeOfString:@"<"];
    
    NSString * result;
    if (range.location != NSNotFound) {
        result = [line substringFromIndex:range.location];
    }
    XCTAssertEqualObjects(expected, result, @"%@ is not equal to %@",result, expected);
}

- (void)testLogToFile
{
    ASLLog * defaultLog = [ASLLog defaultLog];
    NSString * logPath = [NSTemporaryDirectory() stringByAppendingPathComponent:TestLogFile];
    [defaultLog addLogFile:logPath];
    [defaultLog emergency:TestLogOutput];
    [defaultLog emergency:TestLogFormat, @"ASLLog"];
    [defaultLog alert:TestLogOutput];
    [defaultLog alert:TestLogFormat, @"ASLLog"];
    [defaultLog critical:TestLogOutput];
    [defaultLog critical:TestLogFormat, @"ASLLog"];
    [defaultLog error:TestLogOutput];
    [defaultLog error:TestLogFormat, @"ASLLog"];
    [defaultLog warning:TestLogOutput];
    [defaultLog warning:TestLogFormat, @"ASLLog"];
    [defaultLog notice:TestLogOutput];
    [defaultLog notice:TestLogFormat, @"ASLLog"];
    [defaultLog info:TestLogOutput];
    [defaultLog info:TestLogFormat, @"ASLLog"];
    [defaultLog debug:TestLogOutput];
    [defaultLog debug:TestLogFormat, @"ASLLog"];
    NSString *logdata = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:NULL];
    NSArray * logs = [logdata componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [self checkLog:logs[0] forLevel:@"Emergency"];
    [self checkLog:logs[1] forLevel:@"Emergency"];
    [self checkLog:logs[2] forLevel:@"Alert"];
    [self checkLog:logs[3] forLevel:@"Alert"];
    [self checkLog:logs[4] forLevel:@"Critical"];
    [self checkLog:logs[5] forLevel:@"Critical"];
    [self checkLog:logs[6] forLevel:@"Error"];
    [self checkLog:logs[7] forLevel:@"Error"];
    [self checkLog:logs[8] forLevel:@"Warning"];
    [self checkLog:logs[9] forLevel:@"Warning"];
    [self checkLog:logs[10] forLevel:@"Notice"];
    [self checkLog:logs[11] forLevel:@"Notice"];
    [self checkLog:logs[12] forLevel:@"Info"];
    [self checkLog:logs[13] forLevel:@"Info"];
    [self checkLog:logs[14] forLevel:@"Debug"];
    [self checkLog:logs[15] forLevel:@"Debug"];
}


- (NSDictionary *)createInvalidDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithUTF8String:ASL_TIME_FMT_LCL], optASLTimeFormat,
     [NSNumber numberWithInteger:ASL_ENCODE_ASL], optASLTextEncoding,
     [NSNumber numberWithInteger:ASL_FILTER_MASK_DEBUG],optASLFilterMask,
     nil];
}

- (NSDictionary *)createInvalidTimeFormatDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithUTF8String:ASL_MSG_FMT_STD], optASLMessageFormat,
                                        [NSString stringWithFormat:@"MM-DD-mm-ss"], optASLTimeFormat,
                                        [NSNumber numberWithInteger:ASL_ENCODE_ASL], optASLTextEncoding,
                                        [NSNumber numberWithInteger:ASL_FILTER_MASK_UPTO(ASL_LEVEL_ERR)], optASLFilterMask,
                                        nil];
}

- (NSDictionary *)createValidDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithUTF8String:ASL_MSG_FMT_STD], optASLMessageFormat,
                           [NSString stringWithUTF8String:ASL_TIME_FMT_SEC], optASLTimeFormat,
                           [NSNumber numberWithInteger:ASL_ENCODE_ASL], optASLTextEncoding,
                           [NSNumber numberWithInteger:ASL_FILTER_MASK_UPTO(ASL_LEVEL_ERR)], optASLFilterMask,
                           nil];
}

- (void)testOptions
{
    XCTAssertThrows([[ASLLogOptions alloc] init], @"Should throws exceptions for init.");
    
    XCTAssertThrows([ASLLogOptions optionsWithMessageFormat:nil], @"Should throws exceptions for invalid argument.");
    
    XCTAssertThrows([ASLLogOptions optionsFromDictionary:nil], @"Should throws exceptions for null dictionary.");
    
    XCTAssertThrows([ASLLogOptions optionsFromDictionary:[self createInvalidDictionary]], @"Should throws exceptions for invalid argument.");
    
    XCTAssertThrows([ASLLogOptions optionsFromDictionary:[self createInvalidTimeFormatDictionary]], @"Should throws exceptions for invalid time format argument.");
    
    ASLLogOptions * options = [ASLLogOptions optionsWithMessageFormat:TestMessageFormat];
    XCTAssertNotNil(options, @"No options create with format: %@", TestMessageFormat);
    XCTAssertEqualObjects(options.timeFormat, [NSString stringWithUTF8String:ASL_TIME_FMT_LCL], @"Unexpected time format:%@",options.timeFormat);
    XCTAssertEqual(options.filters, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG), @"Unexpected filters: %x", options.filters);
    XCTAssertEqual(options.textEncoding, ASL_ENCODE_SAFE, @"Unexpected filters: %d", options.textEncoding);
   
}

- (void)testMessageFilter
{
    ASLLog *logger = [ASLLog logWithIdent:TestIdentForFilter];
    NSString * logPath = [NSTemporaryDirectory() stringByAppendingPathComponent:TestLogFileForFilter];
    [logger info:@"Log to %@",logPath];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithUTF8String:ASL_MSG_FMT_STD], optASLMessageFormat,
                              [NSString stringWithUTF8String:ASL_TIME_FMT_LCL], optASLTimeFormat,
                              [NSNumber numberWithInteger:ASL_ENCODE_ASL], optASLTextEncoding,
                              [NSNumber numberWithInteger:ASL_FILTER_MASK_DEBUG],optASLFilterMask,
                              nil];
    ASLLogOptions * options = [ASLLogOptions optionsFromDictionary:dict];
    [logger addLogFile:logPath withOptions:options];
    [logger emergency:TestLogOutput];
    [logger emergency:TestLogFormat, @"ASLLog"];
    [logger alert:TestLogOutput];
    [logger alert:TestLogFormat, @"ASLLog"];
    [logger critical:TestLogOutput];
    [logger critical:TestLogFormat, @"ASLLog"];
    [logger error:TestLogOutput];
    [logger error:TestLogFormat, @"ASLLog"];
    [logger warning:TestLogOutput];
    [logger warning:TestLogFormat, @"ASLLog"];
    [logger notice:TestLogOutput];
    [logger notice:TestLogFormat, @"ASLLog"];
    [logger info:TestLogOutput];
    [logger info:TestLogFormat, @"ASLLog"];
    [logger debug:TestLogOutput];
    [logger debug:TestLogFormat, @"ASLLog"];
    
    NSString *logdata = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:NULL];
    NSArray * logs = [logdata componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    int testCount = 0;
    for (NSString * log in logs) {
        if ([log length]) {
            [self checkLog:log forLevel:@"Debug"];
            testCount++;
        }
    }
    XCTAssertEqual(testCount, 2, @"Log debug information %d times.", testCount);
}

@end
