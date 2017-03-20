//
//  VAService.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAService.h"
//#import <CocoaHTTPServer/HTTPServer.h>
#import <RoutingHTTPServer/RoutingHTTPServer.h>
#import "NSString+URLEncode.h"
@interface VAService ()

@property BOOL isHTTPServerRunning;
@property (nonatomic, strong) RoutingHTTPServer *httpServer;

@end

@implementation VAService

#pragma mark Init & Singleton

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isHTTPServerRunning = NO;
        [VAUtil util].service = self;
    }
    return self;
}

+ (instancetype)defaultService
{
    static VAService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VAService alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

#pragma mark HTTP Server

- (void)configureHTTPServer
{
    if (!_httpServer) {
        _httpServer = [[RoutingHTTPServer alloc] init];
        [_httpServer setPort:10086];
        [_httpServer setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]];
        
        [_httpServer handleMethod:@"GET"
                         withPath:@"/dataApi/*.json"
                           target:[VAUtil util].coordinator
                         selector:@selector(retrieveDataViaRequest:withResponse:)];
    }
}

- (BOOL)startHTTPServer
{
    [self configureHTTPServer];
    
    NSError *err;
    if ([_httpServer start:&err]) {
        NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        _isHTTPServerRunning = YES;
        return YES;
    }
    
    NSLog(@"HTTP Server is unable to start, ERROR: %D", [err localizedDescription]);
    return NO;

}
- (void)stopHTTPServer
{
    [_httpServer stop];
    _isHTTPServerRunning = NO;
}

- (NSString *)getBaseURL
{
    return [NSString stringWithFormat:@"http://localhost:%hu/", _httpServer.listeningPort];
}
- (NSString *)URLWithComponent:(NSString *)component
{
    return [[[self getBaseURL] stringByAppendingString:component] stringByAppendingString:@"?mode=ios"];
}

- (NSString *)URLWithComponent:(NSString *)component width:(NSInteger)width height:(NSInteger)height
{
    return [NSString stringWithFormat:@"%@%@?mode=ios&width=%ld&height=%ld", [self getBaseURL], component, width, height];
}

- (NSString *)URLWithComponent:(NSString *)component width:(NSInteger)width height:(NSInteger)height params:(NSDictionary *)params
{

    NSMutableArray *paramsArray = [NSMutableArray new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", [key URLEncode], [obj URLEncode]]];
    }];
    NSString *paramsString = [paramsArray componentsJoinedByString:@"&"];
    
    NSString *returnString = [NSString stringWithFormat:@"%@%@?mode=ios&width=%ld&height=%ld", [self getBaseURL], component, width, height];
    if ([paramsArray count] != 0) {
        returnString = [NSString stringWithFormat:@"%@&%@", returnString, paramsString];
    }
    
    return returnString;
    
}


@end