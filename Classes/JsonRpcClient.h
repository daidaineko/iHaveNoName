//
//  JsonRpcClient.h
//
//  Created by Marcel Stegmann on 28.07.09.
//

#import <Foundation/Foundation.h>

@interface JsonRpcClient : NSObject {
	NSString *protocol;
	NSString *requestId;
	
	NSURL *url;
	
	NSURLConnection *connection;
	NSMutableData *data;
	
	id delegate;
}

@property (nonatomic, retain) NSString *requestId;

@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;

@property (nonatomic, retain) id delegate;

- (id)initWithUrl:(NSURL *)newUrl delegate:(id)newDelegate;

- (void)requestWithMethod:(NSString *)method params:(NSObject *)params;
- (void)requestWithMethod:(NSString *)method;

- (void)requestWithUrl:(NSURL *)requestUrl data:(NSData *)requestData;

// NSURLConnection handling
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

// Delegates
- (void)jsonRpcClientDidStartLoading:(JsonRpcClient *)client;
- (void)jsonRpcClient:(JsonRpcClient *)client didReceiveResult:(id)result;
- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message;
- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message data:(NSData *)responseData;

@end
