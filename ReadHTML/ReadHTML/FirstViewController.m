//
//  FirstViewController.m
//  ReadHTML
//
//  Created by Nguyen Tuan on 20/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize webView = _webView;
@synthesize receivedData = _receivedData;
@synthesize htmlString = _htmlString;
@synthesize maxHTMLWidth = _maxHTMLWidth;

-(void)dealloc
{
    [_htmlString release];
    [_receivedData release];
    [_webView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString*) metaHeader
{
    return @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\">";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    NSURL *url = [NSURL URLWithString:@"http://ftr.fivefilters.org/makefulltextfeed.php?url=gallery.campaignmonitor.com/ViewEmail/r/E4E567504A5F2678&max=3"];
    NSURL *url = [NSURL URLWithString:@"http://gallery.campaignmonitor.com/ViewEmail/r/E4E567504A5F2678/"];
    self.receivedData = [NSMutableData new];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
//    self.webView.scalesPageToFit = YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    CGFloat imageW = 0;
    CGFloat bound; 
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        imageW = 280;
        bound = 320;
    }else {
        imageW = 728;
        bound = 768;
    }
    csv = [self parseHTML:csv];

    self.webView.delegate = self;
//    self.webView.scalesPageToFit = YES;
    self.htmlString = csv;
    NSLog(csv);
    [self.webView loadHTMLString:csv baseURL:nil];
    [csv release];
}

-(NSString*)parseHTML:(NSString*)csv
{
    CGFloat imageW = 0;
    CGFloat bound; 
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        imageW = 280;
        bound = 320;
    }else {
        imageW = 728;
        bound = 768;
    }
    NSString *handleString;
    NSArray *result;
    self.maxHTMLWidth = 0;
    BOOL needParse = YES;
    
    while (needParse) {
        needParse = NO;
        handleString = csv;
        CGFloat scale =  bound / self.maxHTMLWidth;
        //for textcontent
        NSError *error_w;
        NSRegularExpression *exp_w = [NSRegularExpression regularExpressionWithPattern:@"width:[^;]*." options:NSRegularExpressionCaseInsensitive error:&error_w];
        result = [exp_w matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
        
        for (NSTextCheckingResult *dict in result) {
            NSRange ee = [dict range];
            NSString *subString = [csv substringWithRange:ee];
            NSString *value;
            NSRange prefixRange = [subString rangeOfString:@"width:"];
            value = [subString substringFromIndex:(prefixRange.length + prefixRange.location)];                
            CGFloat w = [value floatValue];
            if (w > self.maxHTMLWidth) {
                self.maxHTMLWidth = w;
                needParse = YES;
                break;
            }
            NSString *wstr = [NSString stringWithFormat:@"%.0f",w];
            w *= scale;
            NSString *nwstr = [NSString stringWithFormat:@"%.0f",w];
            NSString *newSubString = [subString stringByReplacingOccurrencesOfString:wstr withString:nwstr];
            if ([handleString rangeOfString:subString].length > 0) {
                handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubString];
            }
        }
        if (needParse) {
            continue;
        }
        csv = handleString;
        
        //    //for image
        NSError *error_i;
        NSRegularExpression *exp_i = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*." options:NSRegularExpressionCaseInsensitive error:&error_i];
        result = [exp_i matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
        
        for (NSTextCheckingResult *dict in result) {
            NSRange ee = [dict range];
            NSString *subString = [csv substringWithRange:ee];
            NSError *error_iw;
            NSRegularExpression *exp_iw = [NSRegularExpression regularExpressionWithPattern:@"width=\"[0-9]*\"" options:NSRegularExpressionCaseInsensitive error:&error_iw];
            NSRange firstMatch = [exp_iw rangeOfFirstMatchInString:subString options:NSMatchingProgress range:NSMakeRange(0, subString.length)];
            
            if (firstMatch.location != NSNotFound) {
                NSString *width = [subString substringWithRange:firstMatch];
                NSString *w = [width stringByReplacingOccurrencesOfString:@"width=\"" withString:@""];
                CGFloat imw = [w floatValue];
                NSString *wstr = [NSString stringWithFormat:@"%.0f",imw];
                imw *= scale;
                NSString *nwstr = [NSString stringWithFormat:@"%.0f",imw];
                NSString *newSubString = [subString stringByReplacingOccurrencesOfString:wstr withString:nwstr];
                if ([handleString rangeOfString:subString].length > 0) {
                    handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubString];
                }
            }else {
                CGFloat percent = scale * 100;
                NSString *pstr = [NSString stringWithFormat:@"%.0f%",percent];
                NSString *newSubstr = [subString stringByReplacingOccurrencesOfString:@"<img" withString:[NSString stringWithFormat:@"<img width=\"%@\"",pstr]];
                handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubstr];
            }
        }
        //for image
        //        NSError *error_i;
        //        NSRegularExpression *exp_i = [NSRegularExpression regularExpressionWithPattern:@"width=\"[0-9]*\"" options:NSRegularExpressionCaseInsensitive error:&error_i];
        //        result = [exp_i matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
        //        
        //        for (NSTextCheckingResult *dict in result) {
        //            NSRange ee = [dict range];
        //            NSString *subString = [csv substringWithRange:ee];
        //            if ([subString hasPrefix:@"width=\""]) {
        //                NSString *value = [subString stringByReplacingOccurrencesOfString:@"width=\"" withString:@""];
        //                CGFloat w = [value floatValue];
        //                if (w < imageW) {
        //                    continue;
        //                }
        //                NSString *wstr = [NSString stringWithFormat:@"%.0f",w];
        //                w *= scale;
        //                NSString *nwstr = [NSString stringWithFormat:@"%.0f",imageW];//[NSString stringWithFormat:@"%.0f",w];
        //                NSString *newSubString = [subString stringByReplacingOccurrencesOfString:wstr withString:nwstr];
        //                if ([handleString rangeOfString:subString].length > 0) {
        //                    handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubString];
        //                }
        //            }else {
        //                CGFloat percent = scale * 100;
        //                NSString *pstr = [NSString stringWithFormat:@"%.0f",percent];
        //            }
        //        }
    }
    
    //for viewport
    NSError *error_v;
    NSRegularExpression *exp_v = [NSRegularExpression regularExpressionWithPattern:@"<meta name=\"viewport\"[^\"]*." options:NSRegularExpressionCaseInsensitive error:&error_v];
    result = [exp_v matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
    
    for (NSTextCheckingResult *dict in result) {
        NSRange ee = [dict range];
        NSString *subString = [csv substringWithRange:ee];
        handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:@""];
    }
    
    
    NSString *metaHeader = [self metaHeader];
    handleString = [handleString stringByReplacingOccurrencesOfString:@"<head>" withString:[NSString stringWithFormat:@"<head>%@",metaHeader]];
    
    return handleString;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
