//
//  XBMCCommunicator.h
//  TheElements
//
//  Created by Martin Guillon on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XBMCHTTPCommunicator : NSObject {
    
    NSDictionary* currentRequest;
    NSMutableArray *requestQueue;
    
    NSString* fulladdress;
    NSMutableData* receivedData;
}

@property (nonatomic, retain) NSString* fulladdress;
@property (nonatomic, retain) NSMutableArray *requestQueue;

+ (XBMCHTTPCommunicator *) sharedInstance;

- (void) setAddress:(NSString*)address port:(NSString*)port login:(NSString*)log password:(NSString*)pwd;
- (void) processNextHTTPRequest;
-(void)addHTTPRequest:(NSObject*)object selector:(SEL)sel request:(NSDictionary*)rq;
- (void)XBMCHTTPCommunicator:(XBMCHTTPCommunicator *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message;
- (void)XBMCHTTPCommunicator:(XBMCHTTPCommunicator *)client didReceiveResult:(id)result ;
- (void)XBMCHTTPCommunicator:(XBMCHTTPCommunicator *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message data:(NSData *)responseData;

-(void)getCurrentPlaying:(NSObject*)object selector:(SEL)sel;

-(BOOL)isNumeric:(NSString*)str;
-(int)getLines: (NSString*) text lines: (NSMutableArray*)theLines;
@end
