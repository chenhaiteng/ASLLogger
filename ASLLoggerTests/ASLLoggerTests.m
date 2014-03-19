//
//  ASLLoggerTests.m
//  ASLLoggerTests
//
//  Created by Chen Hai Teng on 3/18/14.
//  Copyright (c) 2014 Chen-Hai Teng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ASLLog.h"

NSString * const TestIdent = @"UTest";
NSString * const TestLogFile = @"UTest.log";
NSString * const TestLogOutput = @"Hello! ASLLog";
NSString * const TestLogFormat = @"Hello! %@";
NSString * const TestOutputFormat = @"<%@>: Hello! ASLLog";

@interface ASLLoggerTests : XCTestCase

@end

@implementation ASLLoggerTests

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
    NSString * result = [line substringFromIndex:range.location];
    XCTAssertEqualObjects(expected, result, @"%@ is not equal to %@",result, expected);
}
- (void)testDefaultLogger
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

@end
