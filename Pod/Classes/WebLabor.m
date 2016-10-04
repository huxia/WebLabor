//
//  WebLabor.m
//  Pods
//
//  Created by XiaoHuizhe on 15/9/12.
//
//

#import "WebLabor.h"
#import "AFNetworking.h"
#import "RegexKitLite.h"
typedef void (^AF_SUCCESS)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AF_FAILURE)(AFHTTPRequestOperation *operation, NSError* error);
@interface WebLabor(){
    BOOL _isReady;
    NSURLRequest* _lastRequest;
    NSString* _lastHTML;
    NSURL* _lastBaseURL;
}
@property (nonatomic, strong) WVJB_WEBVIEW_TYPE* webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
@end
@implementation WebLabor
@synthesize webView,bridge;
- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)registerHandler:(NSString*)handlerName handler:(WWHandler)handler{
    [self.bridge registerHandler:handlerName handler:handler];
};
- (void)callHandler:(NSString*)handlerName{
    [self.bridge callHandler:handlerName];
}
- (void)callHandler:(NSString*)handlerName data:(id)data{
    [self.bridge callHandler:handlerName data:data];
}
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WWResponseCallback)responseCallback{
    [self.bridge callHandler:handlerName data:data responseCallback:responseCallback];
}

- (void)setupWebViewHost:(NSArray*)domainHosts additionalHeaders:(NSDictionary*)domainHeaders{
    if (!self.webView) {
        self.webView = [[WVJB_WEBVIEW_TYPE alloc] init];
        self.webView.allowsInlineMediaPlayback = true;
    }
    if (!self.bridge) {
        self.bridge = [WebLabor configWebView:self.webView domainHosts:domainHosts domainHeaders:domainHeaders];
    }
}
+ (BOOL)domainTrusted:(NSURL*)url :(NSArray*)hosts{
    NSString* urlHost = url.host.uppercaseString;
    for (NSString* host in hosts) {
        if ([host.uppercaseString isEqualToString:urlHost]) {
            return true;
        }
    }
    return false;
}
+ (WebViewJavascriptBridge*)configWebView:(WVJB_WEBVIEW_TYPE*)webView domainHosts:(NSArray*)hosts domainHeaders:(NSDictionary*)domainHeaders{
    WebViewJavascriptBridge* bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:nil  handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"WebLabor: error, no handler %@", data);
    } resourceBundle:[NSBundle bundleForClass:[WebLabor class]]];
    
    [bridge registerHandler:@"wl:request" handler:^(id data, WVJBResponseCallback responseCallback) {
        // handle request
        NSLog(@"WebLabor: ww-request %@",data);
        id ps = [data objectForKey:@"data"];
        NSDictionary* params = [ps isKindOfClass:[NSDictionary class]] ? (NSDictionary*)ps : nil;
        NSString* rawBody = [ps isKindOfClass:[NSString class]] ? (NSString*)ps : nil;
        
        NSDictionary* headers = [data objectForKey:@"headers"];
        NSString* urlString = [data objectForKey:@"url"];
        NSString* method = [data objectForKey:@"method"];
        NSNumber* timeout = [data objectForKey:@"timeout"];
        
        
        if (!method) {
            if (params.count || rawBody.length) {
                method = @"POST";
            }else{
                method = @"GET";
            }
        }else{
            method = method.uppercaseString;
        }
        
        NSMutableDictionary* allHeaders = [[NSMutableDictionary alloc] init];
        
        
        
        
        NSMutableDictionary* paramsNormal = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* paramsFile = [[NSMutableDictionary alloc] init];
        
        // check for file
        if(params){
            for (NSString* k in params.allKeys) {
                id v = [params objectForKey:k];
                if ([v isKindOfClass:[NSDictionary class]]) {
                    [paramsFile setObject:v forKey:k];
                }else{
                    [paramsNormal setObject:v forKey:k];
                }
            }
        }
        if (paramsFile.count){
            // file
            if(!timeout) timeout = @(180);
        }else if (params.count && !paramsFile.count && ![method isEqualToString:@"GET"]) {
            // kv post
            if(!timeout) timeout = @(60);
            [allHeaders setObject:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", @"utf-8"] forKey:@"Content-Type"];
        }else{
            // raw body
            if(!timeout) timeout = @(60);
        }
        
        NSURL * url = [NSURL URLWithString:urlString];
        if ([self domainTrusted:url :hosts]) {
            // is trusted domain, give him headers
            for (NSString* k in domainHeaders.allKeys) {
                [allHeaders setValue:[domainHeaders objectForKey:k] forKey:k];
            }
        }
        for (NSString* k in headers.allKeys) {
            [allHeaders setValue:[headers objectForKey:k] forKey:k];
        }
        
        
        
        
        
        // success
        AF_SUCCESS success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSString* string  = operation.responseString;
            if(!string) string = @"";
            NSLog(@"WebLabor: WebView request done, %@ %@", url.absoluteString, operation.responseString);
            
            
            NSHTTPURLResponse * response = nil;
            if ([operation.response isKindOfClass:[NSHTTPURLResponse class]]) {
                response = (NSHTTPURLResponse*)operation.response;
            }
            
            responseCallback(@{
                               @"responseText": string,
                               @"data": responseObject ? responseObject : [NSNull null],
                               @"headers": response ? response.allHeaderFields : [NSDictionary dictionary],
                               @"status": @(response ? response.statusCode : 0),
                               });
            
        };
        
        AF_FAILURE failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString* string  = operation.responseString;
            if(!string) string = @"";
            NSLog(@"WebLabor: request failed, %@ %@", url.absoluteString, error.description);
            
            NSHTTPURLResponse * response = nil;
            if ([operation.response isKindOfClass:[NSHTTPURLResponse class]]) {
                response = (NSHTTPURLResponse*)operation.response;
            }
            
            responseCallback(@{
                               @"responseText": string,
                               @"error": error.description,
                               @"headers": response ? response.allHeaderFields : [NSDictionary dictionary],
                               @"status": @(response ? response.statusCode : 0),
                               });
        };
        
        
        AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] init];
        for (NSString* k in allHeaders.allKeys) {
            [manager.requestSerializer setValue:[allHeaders objectForKey:k] forHTTPHeaderField:k];
        }
        if (paramsFile.count) {
            if (![method isEqualToString:@"POST"]) {
                [NSException raise:@"WrongMethod" format:@"only allow post multipart"];
                return;
            }
            [manager POST:url.absoluteString parameters:paramsNormal constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                for (NSString* k in paramsFile.allKeys) {
                    NSDictionary* file = [paramsFile objectForKey:k];
                    NSString* path = [file objectForKey:@"path"];
                    NSString* fileName = [file objectForKey:@"file_name"];
                    NSString* mimeType = [file objectForKey:@"mime_type"];
                    if (!fileName) {
                        fileName = [path stringByReplacingOccurrencesOfRegex:@".*[\\\\\\/]" withString:@""];
                    }
                    if (!mimeType){
                        mimeType = @"application/octet-stream";
                    }
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        NSLog(@"WebLabor: WebView cannot find file for request, %@", path);
                        continue;
                    }
                    NSData* d = [NSData dataWithContentsOfFile:path];
                    if(d)
                        [formData appendPartWithFileData:d name:k fileName:fileName mimeType:mimeType];
                }
                
            } success:success failure:failure];
            return;
        }else{
            
            NSError* serializationError = nil;
            NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:url.absoluteString parameters:params error:&serializationError];
            if (serializationError) {
                failure(nil, serializationError);
                return;
            }
            if (rawBody) {
                [request setHTTPBody:[rawBody dataUsingEncoding:NSUTF8StringEncoding]];
            }
            AFHTTPRequestOperation* o = [manager HTTPRequestOperationWithRequest:request success:success failure:failure];
            [manager.operationQueue addOperation:o];
            
        }
    }];
    return bridge;
}

- (BOOL)isReady{
    if (_isReady)
        return _isReady;
    if ([[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) _isReady = true;
    return _isReady;
}

- (void)load:(NSURLRequest *)request{
    [self load:request domainHosts:@[request.URL.host] domainHeaders:[request isKindOfClass:[NSMutableURLRequest class]] ? ((NSMutableURLRequest*)request).allHTTPHeaderFields : nil];
}
- (void)load:(NSURLRequest *)request domainHosts:(NSArray*)hosts domainHeaders:(NSDictionary*)domainHeaders{
    
    [self setupWebViewHost:hosts additionalHeaders:domainHeaders];
    
    _isReady = false;
    _lastRequest = request;
    _lastHTML = nil;
    _lastBaseURL = nil;
    [self reload];
}
- (void)loadHTML:(NSString*)html baseURL:(NSURL*)url domainHeaders:(NSDictionary*)headers{
    
    [self setupWebViewHost:@[url.host] additionalHeaders:headers];
    
    _isReady = false;
    _lastRequest = nil;
    _lastHTML = html;
    _lastBaseURL = url;
    [self reload];
}

-(void)reload{
    if (_lastRequest) {
        
#if defined WVJB_PLATFORM_OSX
        [[self.webView mainFrame] loadRequest:_lastRequest];
#else
        [self.webView loadRequest:_lastRequest];
#endif
    }else if(_lastHTML){
        
#if defined WVJB_PLATFORM_OSX
        [[self.webView mainFrame] loadHTMLString:_lastHTML baseURL:_lastBaseURL];
#else
        [self.webView loadHTMLString:_lastHTML baseURL:_lastBaseURL];
#endif
    }else{
        [NSException raise:@"NotYetLoaded" format:@"please call [webLabor load:] or [webLabor loadHTML:] first"];
    }
}
@end
