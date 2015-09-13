//
//  WLViewController.m
//  WebLabor
//
//  Created by dashi on 09/13/2015.
//  Copyright (c) 2015 dashi. All rights reserved.
//

#import "WLViewController.h"
#import "WebLabor.h"
@interface WLViewController ()

@property (nonatomic, strong) WebLabor* wl;
@end

@implementation WLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wl = [[WebLabor alloc] init];
    NSString* content  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Test.html" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
    [self.wl loadHTML:content baseURL:[NSURL URLWithString:@"http://dev.huizhe.name/"] domainHeaders:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
