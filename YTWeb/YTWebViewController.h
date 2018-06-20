//
//  YTWebViewController.h
//  YTWebKit
//
//  Created by Wangguibin on 2018/3/22.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTH5LoginDelegate <NSObject>

@optional

- (void)yt_h5LoginBack;

- (void)yt_h5LoginHandlerWithURL:(NSURL *)url;

@end

@protocol YTWebViewDelegate <NSObject>

@optional
- (BOOL)yt_webView:(UIWebView *)webView shouldStartLoad:(NSURL *)url;

- (void)yt_webView:(UIWebView *)webView didFinishedLoad:(NSURL *)url;

- (void)yt_webView:(UIWebView *)webView didStartLoad:(NSURL *)url;

- (void)yt_webView:(UIWebView *)webView didFailLoad:(NSURL *)url withError:(NSError *)error;

@end


//MARK:class YTWKWebController
/**
 UIWebView
 */
@interface YTWebViewController : UIViewController

@property (nonatomic, weak)id<YTWebViewDelegate> delegate;

@property (nonatomic, copy)NSString *urlString;

@property (nonatomic, strong)NSURL *url;
/**
 show web Element title
 Default is YES.
 */
@property (nonatomic, assign)BOOL isShowWebTitle;



@end
