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

void addGap(UIStackView* stack) {
    UILabel* gapLabel = [UILabel new];
    gapLabel.numberOfLines = 0;
    gapLabel.text = @" ";
    [stack addArrangedSubview:gapLabel];
}

@implementation ViewController

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];

	UIStackView* stack = [UIStackView new];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.frame = CGRectInset(self.view.bounds, 20, 60);

	[self.view addSubview:stack];

	self.launchCount = [UILabel new];
	self.launchCount.text = [NSString stringWithFormat:@"Launch count: %ld", (long)[[CrashManager sharedInstance] currentSessionLaunchCount]];
	[stack addArrangedSubview:self.launchCount];

    UILabel* userIDLabel = [UILabel new];
    userIDLabel.numberOfLines = 0;
    userIDLabel.text = [NSString stringWithFormat:@"Your ID: %@", CrashManager.sharedInstance.userID];
    [stack addArrangedSubview:userIDLabel];

    addGap(stack);

    UILabel *noData = [UILabel new];
    bool didCrash = [[CrashManager sharedInstance] didCrashOnPreviousLaunch];
    noData.text = [NSString stringWithFormat:@"Did you crash on last launch: %@", didCrash ? @"YES" : @"No"];
    noData.numberOfLines = 0;
    [stack addArrangedSubview:noData];

	if (didCrash) {
		UIButton* submit = [UIButton new];
		[submit addTarget:self action:@selector(didSelectSendCrashReport) forControlEvents:UIControlEventTouchUpInside];
		[submit setTitle:@"Submit crash report" forState:UIControlStateNormal];
		[submit setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[stack addArrangedSubview:submit];
	}

    addGap(stack);

	{
		UIButton* crashButton = [UIButton new];
		[crashButton setTitle:@"Crash now (assertion)" forState:UIControlStateNormal];
		[crashButton addTarget:self action:@selector(didSelectForceCrashAssertion) forControlEvents:UIControlEventTouchUpInside];
		[crashButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[stack addArrangedSubview:crashButton];
	}

	{
		UIButton* crashButton = [UIButton new];
		[crashButton setTitle:@"Crash now (bad index)" forState:UIControlStateNormal];
		[crashButton addTarget:self action:@selector(didSelectForceCrashBadIndex) forControlEvents:UIControlEventTouchUpInside];
		[crashButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[stack addArrangedSubview:crashButton];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[CrashManager sharedInstance] sendTestEvent];
}

#pragma mark - Interaction

- (void)didSelectSendCrashReport {
	NSString* message = [NSString stringWithFormat:@"This report is for launch number %ld", (long)[CrashManager sharedInstance].lastSessionLaunchCount];
	UIAlertController* reportSender = [UIAlertController alertControllerWithTitle:@"Report Details" message:message preferredStyle:UIAlertControllerStyleAlert];
	[reportSender addAction:[UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[CrashManager sharedInstance] sendCrashReport:self];
	}]];

	[self presentViewController:reportSender animated:YES completion:nil];
}

- (void)didSelectForceCrashAssertion {
	[[CrashManager sharedInstance] crashWithType:CrashTypeAssertion];
}

- (void)didSelectForceCrashBadIndex {
	[[CrashManager sharedInstance] crashWithType:CrashTypeBadIndex];
}

@end
