//
//  UIViewController+Fjord.h
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Fjord)
+ (NSString *)fjordGetUserDefaultKey;

+ (void)fjordSetUserDefaultKey:(NSString *)key;

- (void)fjordSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)fjordAppsFlyerDevKey;

- (NSString *)fjordMainHostUrl;

- (BOOL)fjordNeedShowAdsView;

- (void)fjordShowAdView:(NSString *)adsUrl;

- (NSDictionary *)fjordJsonToDicWithJsonString:(NSString *)jsonString;

- (void)fadeInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

- (void)bounceView:(UIView *)view duration:(NSTimeInterval)duration;

- (void)shakeView:(UIView *)view duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
