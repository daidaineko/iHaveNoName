//
//  XBMCCommunicator.h
//  TheElements
//
//  Created by Martin Guillon on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JsonRpcClient;

@interface XBMCCommunicator : NSObject {
    
    NSDictionary* currentRequest;
    NSMutableArray *requestQueue;
    JsonRpcClient* json;
    
    NSString* fulladdress;
}

@property (nonatomic, retain) NSString* fulladdress;
@property (nonatomic, retain) NSMutableArray *requestQueue;
@property (nonatomic, retain) JsonRpcClient* json;

+ (XBMCCommunicator *) sharedInstance;

- (void) setAddress:(NSString*)address port:(NSString*)port login:(NSString*)log password:(NSString*)pwd;
- (void)jsonRpcClient:(JsonRpcClient *)client didReceiveResult:(id)result;
- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message;
- (void) processNextJsonRequest;
-(void)addJSONRequest:(NSObject*)object selector:(SEL)sel request:(NSDictionary*)rq;
@end
