//
//  ADOBE CONFIDENTIAL
//  __________________
//
//  Copyright 2020 Adobe 
//  All Rights Reserved.
//
//  NOTICE:  All information contained herein is, and remains
//  the property of Adobe and its suppliers, if any. The intellectual
//  and technical concepts contained herein are proprietary to Adobe
//  and its suppliers and are protected by all applicable intellectual
//  property laws, including trade secret and copyright laws.
//  Dissemination of this information or reproduction of this material
//  is strictly forbidden unless prior written permission is obtained
//  from Adobe.
//

#import "ViewController.h"

#import "CrashManager.h"

@interface ViewController ()

@property (nonatomic) UILabel* launchCount;

@end

@implementation ViewController

- (void)loadView {
	[super loadView];

	self.launchCount = [UILabel new];
	self.launchCount.text = [NSString stringWithFormat:@"Launch count: %ld", (long)[[CrashManager sharedInstance] launchCount]];

	UILabel* crashStatus = [UILabel new];
	crashStatus.numberOfLines = 0;
	crashStatus.text = [[CrashManager sharedInstance] shouldCrash] ? @"App will crash in 3 seconds" : @"App may have crashed. Submit previous crash report?";

	UIStackView* stack = [[UIStackView alloc] initWithArrangedSubviews:@[
		self.launchCount,
		crashStatus
	]];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.frame = self.view.bounds;

	[self.view addSubview:stack];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[CrashManager sharedInstance] crashIfNeeded];
}

@end
