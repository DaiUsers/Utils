//
//  YTWebViewController.m
//  YTWebKit
//
//  Created by Wangguibin on 2018/3/22.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import "YTWebViewController.h"

@interface YTWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong)UIWebView *webView;

@property (nonatomic, strong)NSMutableURLRequest *request;

@property (nonatomic, strong)UIButton *callBackButton;

@property (nonatomic, strong)UIButton *popButton;

@property (nonatomic, strong)UIView *customView;

@end

@implementation YTWebViewController

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

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self.request setURL:self.url];
	[self.webView loadRequest:self.request];
	[self.view addSubview:self.webView];

	UIBarButtonItem *customBitem = [[UIBarButtonItem alloc] initWithCustomView:self.customView];
	self.navigationItem.leftBarButtonItem = customBitem;

	self.navigationItem.title = @"Loading...";

	NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
	self.navigationController.navigationBar.titleTextAttributes = dic;
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
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SetupConfig
- (void)setupConfig {
	[self setIsShowWebTitle:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self didFinishLoad_UpdateNavBar];

	if ([self.delegate respondsToSelector:@selector(yt_webView:didFailLoad:withError:)]) {
		[self.delegate yt_webView:webView didFailLoad:webView.request.URL withError:error];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self didFinishLoad_UpdateNavBar];

	if ([self.delegate respondsToSelector:@selector(yt_webView:didFinishedLoad:)]) {
		[self.delegate yt_webView:webView didFinishedLoad:webView.request.URL];
	}

	if (_isShowWebTitle) {
		NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
		self.navigationItem.title = title;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self didFinishLoad_UpdateNavBar];

	if ([self.delegate respondsToSelector:@selector(yt_webView:didStartLoad:)]) {
		[self.delegate yt_webView:webView didStartLoad:webView.request.URL];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	if ([self.delegate respondsToSelector:@selector(yt_webView:shouldStartLoad:)]) {

		BOOL delegateRes = [self.delegate yt_webView:webView shouldStartLoad:request.URL];
		return delegateRes;
	}

	return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setUrl:(NSURL *)url{
	if (self.url == url) {
		return;
	}
	_url = [self cleanURL:url];


}

- (void)setUrlString:(NSString *)urlString{
	_urlString = urlString;
	_url = [self cleanURL:[NSURL URLWithString:urlString]];

}

//
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
		[_callBackButton setImage:[UIImage imageNamed:@"navRuturnBtn"] forState:UIControlStateNormal];
		[_callBackButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
		[_callBackButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
		[_callBackButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
		[_callBackButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
	}
	return _callBackButton;
}

- (UIWebView *)webView {
	if (!_webView) {
		_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
		[_webView setDelegate:self];
		[_webView setScalesPageToFit:YES];
		[_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_webView setContentMode:UIViewContentModeRedraw];
		[_webView setOpaque:YES];
	}
	return _webView;
}

- (NSMutableURLRequest *)request {
	if (!_request) {
		_request = [[NSMutableURLRequest alloc] init];
	}
	return _request;
}

@end
