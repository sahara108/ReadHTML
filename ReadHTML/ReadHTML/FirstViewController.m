//
//  FirstViewController.m
//  ReadHTML
//
//  Created by Nguyen Tuan on 20/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "SBUUtilities.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize webView = _webView;
@synthesize receivedData = _receivedData;
@synthesize htmlString = _htmlString;
@synthesize parser = _parser;
@synthesize scaleFactor = _scaleFactor;

-(void)dealloc
{
    [_parser release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    NSURL *url = [NSURL URLWithString:@"http://ftr.fivefilters.org/makefulltextfeed.php?url=gallery.campaignmonitor.com/ViewEmail/r/E4E567504A5F2678&max=3"];
    NSURL *url = [NSURL URLWithString:@"http://hcm.24h.com.vn/bong-da/giai-ma-chien-thang-cua-chelsea-c48a456063.html"];
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
    CGFloat imageW = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        imageW = 280;
    }else {
        imageW = 728;
    }
    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    self.scaleFactor = CGFLOAT_MAX;
    
    //for textcontent
    NSError *error_w;
    NSRegularExpression *exp_w = [NSRegularExpression regularExpressionWithPattern:@"width:[^;]*." options:NSRegularExpressionCaseInsensitive error:&error_w];
    NSArray *result = [exp_w matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
    NSString *handleString = csv;
    for (NSTextCheckingResult *dict in result) {
        NSRange ee = [dict range];
        NSString *subString = [csv substringWithRange:ee];
        if ([subString hasPrefix:@"width:"] || [subString rangeOfString:@";width:"].length > 0) {
            NSString *value;
            if ([subString hasPrefix:@"width:"]) {
                value = [subString stringByReplacingOccurrencesOfString:@"width:" withString:@""];
            }else {
                value = [subString stringByReplacingCharactersInRange:NSMakeRange(0, [subString rangeOfString:@";width:"].length + [subString rangeOfString:@";width:"].location) withString:@""];
            }
            
            CGFloat w = [value floatValue];
            if (w == 560) {
                NSLog(@"");
            }
            NSString *wstr = [NSString stringWithFormat:@"%.0f",w];
            w *= self.scaleFactor;
            NSString *nwstr = [NSString stringWithFormat:@"%.0f",w];
            NSString *newSubString = [subString stringByReplacingOccurrencesOfString:wstr withString:nwstr];
            if ([handleString rangeOfString:subString].length > 0) {
                handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubString];
            }
        }
    }
    csv = handleString;
    
//    //for image
//    NSError *error_i;
//    NSRegularExpression *exp_i = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*." options:NSRegularExpressionCaseInsensitive error:&error_i];
//    result = [exp_i matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
//    
//    for (NSTextCheckingResult *dict in result) {
//        NSRange ee = [dict range];
//        NSString *subString = [csv substringWithRange:ee];
//        NSString *temptString = subString;
//            NSError *error_iw;
//            NSRegularExpression *exp_iw = [NSRegularExpression regularExpressionWithPattern:@"<width=\"[0-9]*\"" options:NSRegularExpressionCaseInsensitive error:&error_iw];
//            NSRange firstMatch = [exp_iw firstMatchInString:temptString options:NSMatchingProgress range:NSMakeRange(0, temptString.length)].range;
//            NSString *width = [temptString substringWithRange:firstMatch];
//            NSString *v = [width stringByReplacingOccurrencesOfString:@"width=\"" withString:@""];
//            CGFloat imw = [v floatValue];
//            if (imw > imageW) {
//                NSString *nw = [NSString stringWithFormat:@"width=\"%.0f\"",imageW];
//                temptString = [temptString stringByReplacingOccurrencesOfString:width withString:nw];
//            }            
//        handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:temptString];
//    }
    //for image
    NSError *error_i;
    NSRegularExpression *exp_i = [NSRegularExpression regularExpressionWithPattern:@"width=\"[0-9]*\"" options:NSRegularExpressionCaseInsensitive error:&error_i];
    result = [exp_i matchesInString:csv options:NSMatchingProgress range:NSMakeRange(0, csv.length)];
    
    for (NSTextCheckingResult *dict in result) {
        NSRange ee = [dict range];
        NSString *subString = [csv substringWithRange:ee];
        if ([subString hasPrefix:@"width=\""]) {
            NSString *value = [subString stringByReplacingOccurrencesOfString:@"width=\"" withString:@""];
            CGFloat w = [value floatValue];
            if (w < imageW) {
                continue;
            }
            NSString *wstr = [NSString stringWithFormat:@"%.0f",w];
            w *= self.scaleFactor;
            NSString *nwstr = [NSString stringWithFormat:@"%.0f",imageW];//[NSString stringWithFormat:@"%.0f",w];
            NSString *newSubString = [subString stringByReplacingOccurrencesOfString:wstr withString:nwstr];
            if ([handleString rangeOfString:subString].length > 0) {
                handleString = [handleString stringByReplacingOccurrencesOfString:subString withString:newSubString];
            }
        }
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

    
    NSString *metaHeader = [SBUUtilities metaHeader];
    handleString = [handleString stringByReplacingOccurrencesOfString:@"<head>" withString:[NSString stringWithFormat:@"<head>%@",metaHeader]];
    csv = handleString;
    self.webView.delegate = self;
//    self.webView.scalesPageToFit = YES;
    self.htmlString = csv;
    [self.webView loadHTMLString:csv baseURL:nil];
    [csv release];
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
