//
//  WebLabor.h
//  Pods
//
//  Created by XiaoHuizhe on 15/9/12.
//
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

typedef void (^WWResponseCallback)(id responseData);
typedef void (^WWHandler)(id data, WWResponseCallback responseCallback);

@interface WebLabor : NSObject
@property (nonatomic, readonly) BOOL isReady;
- (void)registerHandler:(NSString*)handlerName handler:(WWHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)load:(NSURLRequest*)request;
- (void)load:(NSURLRequest*)request domainHosts:(NSArray*)hosts domainHeaders:(NSDictionary*)headers;
- (void)loadHTML:(NSString*)html baseURL:(NSURL*)url domainHeaders:(NSDictionary*)headers;
- (void)reload;
+ (WebViewJavascriptBridge*)configWebView:(WVJB_WEBVIEW_TYPE*)webView domainHosts:(NSArray*)hosts domainHeaders:(NSDictionary*)headers;
@end
