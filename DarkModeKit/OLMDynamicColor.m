//
//  Copyright 2013-2019 Microsoft Inc.
//

#import "OLMDynamicColor.h"
#import "DMTraitCollection.h"

@interface OLMDynamicColorProxy : NSProxy <NSCopying>

@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;

@property (nonatomic, readonly) UIColor *resolvedColor;

@end

@implementation OLMDynamicColorProxy

// TODO: We need a more generic initializer.
- (instancetype)initWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor
{
  self.lightColor = lightColor;
  self.darkColor = darkColor;

  return self;
}

- (UIColor *)resolvedColor
{
  if (DMTraitCollection.currentTraitCollection.userInterfaceStyle == DMUserInterfaceStyleDark)
  {
    return self.darkColor;
  }
  else
  {
    return self.lightColor;
  }
}

// MARK: UIColor

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha
{
  return [[OLMDynamicColor alloc] initWithLightColor:[self.lightColor colorWithAlphaComponent:alpha]
                                           darkColor:[self.darkColor colorWithAlphaComponent:alpha]];
}

// MARK: NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  return [self.resolvedColor methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
  [invocation invokeWithTarget:self.resolvedColor];
}

// MARK: NSObject

- (BOOL)isKindOfClass:(Class)aClass
{
  static OLMDynamicColor *dynamicColor = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dynamicColor = [[OLMDynamicColor alloc] init];
  });
  return [dynamicColor isKindOfClass:aClass];
}

// MARK: NSCopying

- (id)copy {
  return [self copyWithZone:nil];
}

- (id)copyWithZone:(NSZone *)zone {
  return [[OLMDynamicColorProxy alloc] initWithLightColor:self.lightColor darkColor:self.darkColor];
}

@end

// MARK: -

@implementation OLMDynamicColor

- (UIColor *)initWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor
{
  return (OLMDynamicColor *)[[OLMDynamicColorProxy alloc] initWithLightColor:lightColor darkColor:darkColor];
}

- (UIColor *)lightColor
{
  NSAssert(NO, @"This should never be called");
  return nil;
}

- (UIColor *)darkColor
{
  NSAssert(NO, @"This should never be called");
  return nil;
}

@end
