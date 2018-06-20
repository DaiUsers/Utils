//
//  YTWKWebController.m
//  YTWebKit
//
//  Created by Wangguibin on 2018/3/26.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import "YTWKWebController.h"

@interface YTWKWebController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler> {
	NSTimeInterval _firstTime;
	NSTimeInterval _lastTime;
}

@property (nonatomic, strong)NSMutableURLRequest *request;

@property (nonatomic, strong)WKWebView *webView;

@property (nonatomic, strong)WKNavigation *webNavigation;

@property (nonatomic, strong)WKWebViewConfiguration *webConfiguration;

/**
 进度条
 */
@property (nonatomic, strong)UIProgressView *progressView;

@property (nonatomic, strong)UIButton *callBackButton;

@property (nonatomic, strong)UIButton *popButton;

@property (nonatomic, strong)UIView *customView;


/**
 存储JSAction: Dictionary (name: handler)
 */
@property (nonatomic, strong)NSMutableDictionary *messageHandlers;

@end

#define StatusHeight UIApplication.sharedApplication.statusBarFrame.size.height

static NSString *const YTEstimatedProgressKeyPath = @"estimatedProgress";
static NSString *const YTTitleKeyPath = @"title";

@implementation YTWKWebController

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setupConfig];
	}
	return self;
}

- (instancetype)initWithURL:(NSURL *)url {
	self = [super init];
	if (self) {
		_url = [self cleanURL:url];
		[self setupConfig];
		[self.request setURL:_url];
	}
	return self;
}

- (instancetype)initWithURLString:(NSString *)urlString {
	self = [super init];
	if (self) {
		_url = [self cleanURL:[NSURL URLWithString:urlString]];
		[self setupConfig];
	}
	return self;
}

- (void)setUrl:(NSURL *)url{
	_url = [[self cleanURL:url] copy];
	[self setupConfig];
}

- (void)setUrlString:(NSString *)urlString{
	_urlString = [urlString copy];
	_url = [self cleanURL:[NSURL URLWithString:_urlString]];
	[self setupConfig];
}

- (void)loadView {
	[super loadView];
	[self loadWebRequest];
}

	//加载web数据
- (void)loadWebRequest {

	[self.request setURL:self.url];
	if (self.webView.isLoading) {
		return;
	}

	[self.webView loadRequest:self.request];
	NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
	_firstTime = nowTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self setupNav];
	[self.view addSubview:self.webView];
	[self.view addSubview:self.progressView];
}

- (void)setupNav {
	UIBarButtonItem *customBitem = [[UIBarButtonItem alloc] initWithCustomView:self.customView];
	self.navigationItem.leftBarButtonItem = customBitem;

	NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
	self.navigationController.navigationBar.titleTextAttributes = dic;

	self.navigationItem.title = @"Loading...";
}


- (void)upDateLeftNavigationBarButton {

	if ([self.webView canGoBack]) {
		self.navigationController.interactivePopGestureRecognizer.enabled = NO;
		[self.popButton setHidden:NO];
	} else {
		self.navigationController.interactivePopGestureRecognizer.enabled = YES;
		[self.popButton setHidden:YES];
	}
}

- (void)backButtonAction {
	if ([self.webView canGoBack]) {
		[self.webView goBack];
	} else {
		[self closeButtonAction];
	}
}

- (void)closeButtonAction {
	[self selfClean];

	if ([self.delegate respondsToSelector:@selector(yt_dismissWKWebController:)]) {
		[self.delegate yt_dismissWKWebController:self];
		return;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SetupConfig
- (void)setupConfig {
	//默认显示web标题
	[self setIsShowWebTitle:YES];
	//默认显示进度条
	[self setIsShowProgress:YES];
	//默认进度条颜色(red)
	[self setProgressTintColor:[UIColor redColor]];
	//默认进度条背景色
	[self setProgressTrackColor:[UIColor clearColor]];
}

- (NSURL *)cleanURL:(NSURL *)url {
	if (url.scheme.length == 0) {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[url absoluteString]]];
	}
	return url;
}

- (void)didFinishLoad_UpdateNavBar {
	[self upDateLeftNavigationBarButton];
}

	///MARK: Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

	if ([keyPath isEqualToString:YTEstimatedProgressKeyPath]) {
		//进度条监听回调
		CGFloat progress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
		if (progress == 1) {
			[self.progressView setHidden:YES];
			[self.progressView setProgress:0 animated:NO];
		} else {
			[self.progressView setHidden:NO];
			[self.progressView setProgress:progress animated:YES];
		}
	} else if ([keyPath isEqualToString:YTTitleKeyPath]) {
		NSString *title = [change objectForKey:NSKeyValueChangeNewKey];
		self.navigationItem.title = title;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//清除
- (void)selfClean {
	for (NSString *name in self.messageHandlers.allKeys) {
		[self.webConfiguration.userContentController removeScriptMessageHandlerForName: name];
	}
	[self.messageHandlers removeAllObjects];

	self.request = nil;
	self.webConfiguration = nil;
	self.webNavigation = nil;
	self.webView = nil;

}

- (void)dealloc {
	NSLog(@"销毁了");
}

- (void)yt_registerJSName:(NSString *)name actionHandler:(YT_JSHandler)handler {
	[self.webConfiguration.userContentController addScriptMessageHandler:self name:name];
	self.messageHandlers[name] = [handler copy];
}

#pragma mark - WKNavigationDelegate

// 在发送请求之前,决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	//返回结果(默认 Allow)
	WKNavigationActionPolicy handler = WKNavigationActionPolicyAllow;

	//YTWKWebDelegate	shouldStartRequest
	if ([self.delegate respondsToSelector:
		 @selector(yt_WKWebView:shouldStartRequest:)]) {
		BOOL res = [self.delegate yt_WKWebView:webView shouldStartRequest:navigationAction.request.URL];
		if (!res) {
			handler = WKNavigationActionPolicyCancel;
		}
	}

	decisionHandler(handler);
}

	//在收到响应之后,决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {

	//返回结果(默认 Allow)
	WKNavigationResponsePolicy handler = WKNavigationResponsePolicyAllow;

	//YTWKWebDelegate shouldStartLoadResponse
	if ([self.delegate respondsToSelector:
		 @selector(yt_WKWebView:shouldStartLoadResponse:)]) {
		BOOL res = [self.delegate yt_WKWebView:webView shouldStartLoadResponse:navigationResponse.response];
		if (!res) {
			handler = WKNavigationResponsePolicyCancel;
		}
	}

	decisionHandler(handler);
}

//页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
	[self didFinishLoad_UpdateNavBar];

	//YTWKWebDelegate didStartLoad
	if ([self.delegate respondsToSelector:
		 @selector(yt_WKWebView:didStartLoad:)]) {
		[self.delegate yt_WKWebView:webView didStartLoad:webView.URL];
	}
}

//页面内容开始返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
	
//	NSLog(@"%@",webView.URL.absoluteString);
}

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
	_lastTime = nowTime;
	NSLog(@"web 加载时间 %f", _lastTime - _firstTime);

	[self didFinishLoad_UpdateNavBar];

	//YTWKWebDelegate didFinishedLoad
	if ([self.delegate respondsToSelector:
		 @selector(yt_WKWebView:didFinishedLoad:)]) {
		[self.delegate yt_WKWebView:webView didFinishedLoad:webView.URL];
	}
}

//页面加载失败调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {

	[self didFinishLoad_UpdateNavBar];

	//YTWKWebDelegate	didFailLoad
	if ([self.delegate respondsToSelector:
		 @selector(yt_WKWebView:didFailLoad:withError:)]) {
		[self.delegate yt_WKWebView:webView didFailLoad:webView.URL withError:error];
	}
}

//权限认证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

		if ([challenge previousFailureCount] == 0) {
			NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
		} else {
			completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
		}
	} else {
		completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
	}
}

//收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {

	NSLog(@"---ServerRedirect-->\n%@\n", navigation);
}


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
	NSLog(@"-=====> %@",webView.URL.absoluteString);
}

#pragma mark - WKUIDelegate

//创建一个新的web
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

	[webView loadRequest:navigationAction.request];
	return nil;
}

//警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

}

//输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {

}

//确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

	YT_JSHandler handler = self.messageHandlers[message.name];
	if (handler) {
		handler(message.body);
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//MARK: Lazy-var
- (UIView *)customView {
	if (!_customView) {
		_customView = [[UIView alloc] init];
		[_customView setFrame:CGRectMake(-15, 0, 88, 44)];
		[_customView addSubview:self.callBackButton];
		[_customView addSubview:self.popButton];
	}
	return _customView;
}

	//直接返回
- (UIButton *)popButton {
	if (!_popButton) {
		_popButton = [[UIButton alloc] init];
		[_popButton setFrame:CGRectMake(38, 0, 44, 44)];
		[_popButton setTitle:@"关闭" forState: UIControlStateNormal];
		[_popButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
		[_popButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[_popButton setHidden:YES];
	}
	return _popButton;
}

	//返回一层
- (UIButton *)callBackButton {
	if (!_callBackButton) {
		_callBackButton = [[UIButton alloc] init];
		[_callBackButton setFrame:CGRectMake(0, 0, 40, 44)];
		[_callBackButton setTitle:@"返回" forState: UIControlStateNormal];
		[_callBackButton setImage:self.backImage forState:UIControlStateNormal];
		[_callBackButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
		[_callBackButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
		[_callBackButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
		[_callBackButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
	}
	return _callBackButton;
}

- (UIImage *)backImage {
	if (!_backImage) {
		_backImage = [UIImage imageNamed:@"webBack"];
	}
	return _backImage;
}

- (UIProgressView *)progressView {
	if (!_progressView) {
		_progressView = [[UIProgressView alloc] init];
		[_progressView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
		[_progressView setTintColor:self.progressTintColor];
		[_progressView setTrackTintColor:self.progressTrackColor];
	}
	return _progressView;
}

- (WKWebView *)webView {
	if (!_webView) {
		_webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.webConfiguration];
		[_webView setUIDelegate:self];
		[_webView setNavigationDelegate:self];
		[_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_webView setContentMode:UIViewContentModeRedraw];
		[_webView setOpaque:YES];
		if (self.isShowProgress) {
			//监听进度
			[_webView addObserver:self forKeyPath:YTEstimatedProgressKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}

		if (self.isShowWebTitle) {
			//web标题
			[_webView addObserver:self forKeyPath:YTTitleKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}
		NSLog(@"Init WebView");
	}
	return _webView;
}

- (WKWebViewConfiguration *)webConfiguration {
	if (!_webConfiguration) {
		_webConfiguration = [[WKWebViewConfiguration alloc] init];
	}
	return _webConfiguration;
}

- (NSMutableURLRequest *)request {
	if (!_request) {
		_request = [[NSMutableURLRequest alloc] init];
		NSLog(@"Init Request");
	}
	return _request;
}

- (NSMutableDictionary *)messageHandlers {
	if (!_messageHandlers) {
		_messageHandlers = [[NSMutableDictionary alloc] init];
	}
	return _messageHandlers;
}



@end
