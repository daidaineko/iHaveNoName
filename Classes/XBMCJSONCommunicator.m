//
//  XBMCCommunicator.m
//  TheElements
//
//  Created by Martin Guillon on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBMCCommunicator.h"
#import "JsonRpcClient.h"


@implementation XBMCCommunicator
@synthesize json;
@synthesize requestQueue;
@synthesize fulladdress;
static XBMCCommunicator *sharedInstance = nil;

#pragma mark -
#pragma mark Initialisation


+ (XBMCCommunicator *) sharedInstance {
	return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

- (void) setAddress:(NSString*)address port:(NSString*)port login:(NSString*)log password:(NSString*)pwd
{
//    fulladdress = @"test";
    fulladdress = [NSString stringWithFormat:@"%@:%@@%@:%@",log,pwd,address,port];
    json = [[JsonRpcClient alloc] initWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/jsonrpc",fulladdress]]  delegate:self];
    [json setRequestId:@"1"];
}

- (NSString*) getFullAddress
{
    return fulladdress;
}


- (id) init
{
    self = [super init];
    if (self)
    {
        currentRequest = nil;
        requestQueue = [[NSMutableArray arrayWithCapacity:0] retain];
    }
    return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc;
{
	[super dealloc];
    [requestQueue removeAllObjects];
    [fulladdress release];
    [currentRequest release];
    [JsonRpcClient release];

}

-(void)processNextJsonRequest
{
    if (!json) return;
    if (currentRequest == nil)
    {
        currentRequest = [requestQueue lastObject];
        [requestQueue removeLastObject];
        [json requestWithMethod:[[currentRequest objectForKey:@"request"] objectForKey:@"cmd"] 
                         params:[[currentRequest objectForKey:@"request"] objectForKey:@"params"]];
    }
}


-(void)addJSONRequest:(NSObject*)object selector:(SEL)sel request:(NSDictionary*)rq
{
    NSDictionary *request = [[NSDictionary alloc] initWithObjectsAndKeys:
                             rq, @"request", [NSValue valueWithPointer:sel], @"selector"
                             , object, @"object",nil];
    [requestQueue insertObject:request atIndex:0];
    [self processNextJsonRequest];  
    
}

- (void)jsonRpcClient:(JsonRpcClient *)client didReceiveResult:(id)result 
{
    
    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithBool:FALSE], @"failure", [currentRequest objectForKey:@"request"], @"request", result, @"result",nil];
    
    id <NSObject> obj = [currentRequest objectForKey:@"object"];
    if (obj) {
        SEL aSel = [[currentRequest objectForKey:@"selector"] pointerValue];
        if ([obj respondsToSelector:aSel])
            [obj performSelector:aSel withObject:resultDict];
    }
    
    
    [currentRequest release];
    currentRequest = nil;
    if ([requestQueue count] != 0)
    {
        [self processNextJsonRequest];
    }
}

- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message {
    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithBool:TRUE], @"failure", [currentRequest objectForKey:@"request"], @"request", code, @"core", message, @"message",nil];
    
    id <NSObject> obj = [currentRequest objectForKey:@"object"];
    if (obj) {
        SEL aSel = [[currentRequest objectForKey:@"selector"] pointerValue];
        if ([obj respondsToSelector:aSel])
            [obj performSelector:aSel withObject:resultDict];
    }
    
    
    [currentRequest release];
    currentRequest = nil;
    if ([requestQueue count] != 0)
    {
        [self processNextJsonRequest];
    }
}


@end
