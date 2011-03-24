//
//  JsonRpcClient.m
//
//  Created by mstegmann on 28.07.09.
//

#import "JsonRpcClient.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

@implementation JsonRpcClient

@synthesize requestId;

@synthesize url;

@synthesize connection;
@synthesize data;

@synthesize delegate;

- (id)init {
	self = [super init];
	protocol = @"2.0";
	requestId = @"0";
	return self;
}

- (id)initWithUrl:(NSURL *)newUrl delegate:(id)newDelegate {
	self = [self init];
	self.url = newUrl;
	self.delegate = newDelegate;
	
	return self;
}

- (void)requestWithMethod:(NSString *)method params:(NSObject *)dict {
	NSArray *jsonRpc = [NSDictionary dictionaryWithObjectsAndKeys:
						protocol, @"jsonrpc",
						method, @"method",
						dict, @"params",
						requestId, @"id",
						nil];
	
	NSString *serialized = [[CJSONSerializer serializer] serializeObject:jsonRpc];
//    NSLog(@"sending message %@", serialized);
	NSData *serializedData = [serialized dataUsingEncoding:NSUTF8StringEncoding];
	
	[self requestWithUrl:url data:serializedData];
}

- (void)requestWithMethod:(NSString *)method {
	[self requestWithMethod:method params:[NSArray array]];
}

- (void)requestWithUrl:(NSURL *)requestUrl data:(NSData *)requestData {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
	[request setValue:[[NSNumber numberWithInt:[requestData length]] stringValue] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody: requestData];
	
	data = nil;
	connection = nil;
	
	data = [[NSMutableData alloc] init];	
	connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self jsonRpcClientDidStartLoading:self];
}

// NSURLConnection delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData {
	[data appendData: newData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self jsonRpcClient:self didFailWithErrorCode:[NSNumber numberWithInt:0] message:@"Connection to server failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
	
	NSError *error = nil;
	NSDictionary *dictionary = [jsonDeserializer deserializeAsDictionary:data error:&error];
	
	// Handle parse error
	if(error) {
		[self jsonRpcClient:self didFailWithErrorCode:[NSNumber numberWithInt:[error code]] message:@"Unable to parse server response" data: data];
		return;
	}
	
	// Handle error from server
	if([dictionary objectForKey:@"error"]) {
		NSDictionary *serverError = [dictionary objectForKey:@"error"];
		[self jsonRpcClient:self didFailWithErrorCode:[serverError objectForKey:@"code"] message:[serverError objectForKey:@"message"] data: data];
		return;
	}
	
	// Handle success
	[self jsonRpcClient:self didReceiveResult:[dictionary objectForKey:@"result"]];
}

# pragma mark delegate

- (void)jsonRpcClientDidStartLoading:(JsonRpcClient *)client {
	if([[self delegate] respondsToSelector:@selector(jsonRpcClientDidStartLoading:)]) {
		[[self delegate] jsonRpcClientDidStartLoading:client];
	}		
}

- (void)jsonRpcClient:(JsonRpcClient *)client didReceiveResult:(id)result {
	if([[self delegate] respondsToSelector:@selector(jsonRpcClient:didReceiveResult:)]) {
		[[self delegate] jsonRpcClient:client didReceiveResult:result];
	}	
}

- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message {
	if([[self delegate] respondsToSelector:@selector(jsonRpcClient:didFailWithErrorCode:message:)]) {
		[[self delegate] jsonRpcClient:client didFailWithErrorCode:code message: message];
	}	
}

// Fail delegate with data (for debugging purpose)
- (void)jsonRpcClient:(JsonRpcClient *)client didFailWithErrorCode:(NSNumber *)code message:(NSString *)message data:(NSData *)responseData {
	if([[self delegate] respondsToSelector:@selector(jsonRpcClient:didFailWithErrorCode:message:data:)]) {
		[[self delegate] jsonRpcClient:client didFailWithErrorCode:code message: message data:responseData];
	}
	
	// Call also the delegate without data
	[self jsonRpcClient:self didFailWithErrorCode:code message:message];
}

- (void)dealloc {
	[requestId release];
	[url release];
	[connection release];
	[data release];
	[super dealloc];
}

@end
