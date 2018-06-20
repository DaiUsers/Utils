//
//  YTWKWebController.h
//  YTWebKit
//
//  Created by Wangguibin on 2018/3/26.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class YTWKWebController;

@protocol YTWKWebDelegate <NSObject>

@optional

/**
 是否进行请求

 @param webView wkwebView
 @param url request_URL
 @return Default is YES
 */
- (BOOL)yt_WKWebView:(WKWebView *)webView shouldStartRequest:(NSURL *)url;

/**
 是否进行加载response

 @param webView wkwebView
 @param response web_response
 @return Default is YES
 */
- (BOOL)yt_WKWebView:(WKWebView *)webView shouldStartLoadResponse:(NSURLResponse *)response;

/**
 加载完成

 @param webView wkwebView
 @param url didLoad_URL
 */
- (void)yt_WKWebView:(WKWebView *)webView didFinishedLoad:(NSURL *)url;

/**
 开始加载

 @param webView wkwebView
 @param url startLoad_URL
 */
- (void)yt_WKWebView:(WKWebView *)webView didStartLoad:(NSURL *)url;

/**
 加载失败

 @param webView wkwebView
 @param url failLoad_URL
 @param error NSError
 */
- (void)yt_WKWebView:(WKWebView *)webView didFailLoad:(NSURL *)url withError:(NSError *)error;


/**
 手动返回(用于非push操作)

 @param controller YTWKWebController
 */
- (void)yt_dismissWKWebController:(YTWKWebController *)controller;

@end

/**
 js调OC -> window.webkit.messageHandlers.<方法名>.postMessage(<body>)

 @param responseData 返回Body(id)
 */
typedef void(^YT_JSHandler)(id responseData);


//MARK:class YTWKWebController
/**
 UIWKWeb
 */
@interface YTWKWebController : UIViewController

@property (nonatomic, weak)id <YTWKWebDelegate>delegate;

@property (nonatomic, copy)NSString *urlString;

@property (nonatomic, strong)NSURL *url;

/**
 返回按钮图片
 Default is webBack.png
 */
@property (nonatomic, strong)UIImage *backImage;

/**
 show web Element title
 Default is YES.
 */
@property (nonatomic, assign)BOOL isShowWebTitle;

/**
 是否显示进度条
 Default is YES
 */
@property (nonatomic, assign)BOOL isShowProgress;

/**
 进度条颜色
 Default is Red
 */
@property (nonatomic, strong)UIColor *progressTintColor;

/**
 进度条背景色
 Default is Clear
 */
@property (nonatomic, strong)UIColor *progressTrackColor;

/**
 缩放网页内容
 是否允许放大手势来放大网页内容
 */
@property (nonatomic, assign)BOOL allowsMagnification;

/**
 影响网页内容放缩的因子
 默认值是1.0
 */
@property(nonatomic, assign) CGFloat magnification;

/**
 1.实例化方法

 @param url url
 @return obj
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 2.实例化方法

 @param urlString string
 @return obj
 */
- (instancetype)initWithURLString:(NSString *)urlString;

/**
 注册js方法

 @param name 方法名
 @param handler 回调
 */
- (void)yt_registerJSName:(NSString *)name actionHandler:(YT_JSHandler)handler;

@end
