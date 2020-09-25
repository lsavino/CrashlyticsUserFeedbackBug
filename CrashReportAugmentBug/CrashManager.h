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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
	CrashTypeAssertion,
    CrashTypeException,
	CrashTypeBadIndex,
} CrashType;

@interface CrashManager : NSObject

@property (readonly) NSInteger lastSessionLaunchCount;
@property (readonly) NSInteger currentSessionLaunchCount;
@property (readonly) BOOL didCrashOnPreviousLaunch;

+ (instancetype)sharedInstance;

- (void)setUpOnce;

- (void)incrementLaunchCount;

- (void)crashWithType:(CrashType)type;

- (void)sendCrashReport:(UIViewController*)parent;

- (void)sendTestEvent;

- (NSString*)userID;

@end

NS_ASSUME_NONNULL_END
