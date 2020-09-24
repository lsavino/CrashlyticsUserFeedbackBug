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

#import "CrashManager.h"

#import "Firebase.h"

@interface CrashManager()

@end

static NSString* kLaunchCountKey = @"CrashTestLaunchCount";

@implementation CrashManager

+ (instancetype)sharedInstance {
	static CrashManager* _manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_manager = [CrashManager new];
	});

	return _manager;
}

- (void)setUpOnce {
	[FIRApp configure];
}

- (void)incrementLaunchCount {
	[[NSUserDefaults standardUserDefaults] setInteger:self.launchCount + 1 forKey:kLaunchCountKey];
}

- (void)resetLaunchCount {
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kLaunchCountKey];
}

- (NSInteger)launchCount {
	return [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchCountKey];
}

- (BOOL)shouldCrash {
	return self.launchCount % 2 == 1;
}

- (void)crashIfNeeded {
	if (!self.shouldCrash) {
		return;
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSArray* items = @[@"a"];
		NSString* i = items[2];
		NSLog(@"Crashed with %@", i);
	});
}

- (void)sendCrashReport {
	[[FIRCrashlytics crashlytics] logWithFormat:@"Intentional crash with launch count == %ld", (long)self.launchCount];
}

- (void)sendTestEvent {
	[FIRAnalytics logEventWithName:@"Test sample app event logging" parameters:@{
		@"Launch count" : [NSString stringWithFormat:@"%ld", (long)self.launchCount]
	}];
}

@end
