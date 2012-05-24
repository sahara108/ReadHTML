//
//  FirstViewController.h
//  ReadHTML
//
//  Created by Nguyen Tuan on 20/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FirstViewController : UIViewController<UIWebViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *htmlString;
@property (nonatomic, assign) CGFloat maxHTMLWidth;

@end
