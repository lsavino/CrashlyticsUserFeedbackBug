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

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];


	UIStackView* stack = [UIStackView new];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.frame = CGRectInset(self.view.bounds, 20, 60);

	[self.view addSubview:stack];

	self.launchCount = [UILabel new];
	self.launchCount.text = [NSString stringWithFormat:@"Launch count: %ld", (long)[[CrashManager sharedInstance] launchCount]];
	[stack addArrangedSubview:self.launchCount];

	if ([[CrashManager sharedInstance] willAutoCrash]) {
		UILabel* crashStatus = [UILabel new];
		crashStatus.numberOfLines = 0;
		crashStatus.text = @"App will crash in 3 seconds";
		[stack addArrangedSubview:crashStatus];
	}

	if ([[CrashManager sharedInstance] didCrashOnPreviousLaunch]) {
		UILabel* crashStatus = [UILabel new];
		crashStatus.numberOfLines = 0;
		crashStatus.text = @"App may have crashed. Submit previous crash report?";
		[stack addArrangedSubview:crashStatus];

		UIButton* submit = [UIButton new];
		[submit addTarget:self action:@selector(didSelectSendCrashReport) forControlEvents:UIControlEventTouchUpInside];
		[submit setTitle:@"Submit crash report" forState:UIControlStateNormal];
		[submit setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[stack addArrangedSubview:submit];
	}

	if (![[CrashManager sharedInstance] willAutoCrash] && ![[CrashManager sharedInstance] didCrashOnPreviousLaunch]) {
		UILabel *noData = [UILabel new];
		noData.text = @"App won't crash, but Crashlytics thinks the previous launch didn't crash either.";
		noData.numberOfLines = 0;
		[stack addArrangedSubview:noData];
	}

	{
		UIButton* crashButton = [UIButton new];
		[crashButton setTitle:@"Crash now" forState:UIControlStateNormal];
		[crashButton addTarget:self action:@selector(didSelectForceCrash) forControlEvents:UIControlEventTouchUpInside];
		[crashButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[stack addArrangedSubview:crashButton];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[CrashManager sharedInstance] sendTestEvent];
	[[CrashManager sharedInstance] crashWithType:CrashTypeConditional];
}

#pragma mark - Interaction

- (void)didSelectSendCrashReport {

	NSString* message = [NSString stringWithFormat:@"This report is for launch number %ld", (long)[CrashManager sharedInstance].launchCount];
	UIAlertController* reportSender = [UIAlertController alertControllerWithTitle:@"Report Details" message:message preferredStyle:UIAlertControllerStyleAlert];
	[reportSender addAction:[UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[CrashManager sharedInstance] sendCrashReport];
	}]];

	[self presentViewController:reportSender animated:YES completion:nil];
}

- (void)didSelectForceCrash {
	[[CrashManager sharedInstance] crashWithType:CrashTypeAlways];
}

@end
