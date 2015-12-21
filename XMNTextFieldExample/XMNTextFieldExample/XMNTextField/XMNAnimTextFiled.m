//
//  XMNAnimTextFiled.m
//  XMNTextFieldExample
//
//  Created by ChenMaolei on 15/12/16.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNAnimTextFiled.h"

#define kXMNMinFontSize  10
#define kXMNMaxFontSize  16


#pragma mark - _XMNBorderLayer 内部类

/**
 *  _XMNBorderLayer 内部类,提供顶部可变化的边框
 */
@interface _XMNBorderLayer : CAShapeLayer

@property (nonatomic, assign) CGFloat start;
@property (nonatomic, assign) CGFloat end;

@end


@implementation _XMNBorderLayer

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"start"] || [key isEqualToString:@"end"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (instancetype)init {
    if ([super init]) {
        self.start = self.end = .5f;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextMoveToPoint(ctx, self.start * self.frame.size.width, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, self.end * self.frame.size.width, 0);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, self.borderColor);
    CGContextStrokePath(ctx);
}

@end


/**
 *  一个输入框,输入文字时又动画效果
 */
@interface XMNAnimTextFiled ()<UITextFieldDelegate>

{
    /** 缩放的percent = (placeHolderIV.width*self.min + placeHolderL.width*self.min+ 10 + 8) / (self.width * 2) */
    CGFloat _percent;
}

@property (nonatomic, strong) _XMNBorderLayer *borderLayer;

@property (nonatomic, strong) UIImageView *tipsIV;
@property (nonatomic, strong) UIImageView *placeHolderIV;
@property (nonatomic, strong) UILabel *placeHolderL;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation XMNAnimTextFiled

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self setup];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidBeginEditingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object == self.textField) {
                [self setState:XMNAnimTextFieldStateEditing];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidEndEditingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object == self.textField) {
                [self setState:XMNAnimTextFieldStateNormal];
            }
        }];
       
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.tipsIV.hidden) {
        self.textField.frame = CGRectMake(10, 6, self.bounds.size.width - 20, self.bounds.size.height - 12);
    }else {
        self.textField.frame = CGRectMake(10, 6, self.bounds.size.width - 20 - self.tipsIV.frame.size.width - 10, self.bounds.size.height - 12);
    }
    self.tipsIV.frame = CGRectMake(self.bounds.size.width - 10 - self.tipsIV.frame.size.width, self.bounds.size.height/2 - self.tipsIV.frame.size.height/2, self.tipsIV.frame.size.width, self.tipsIV.frame.size.height);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    
}

#pragma mark - XMNAnimTextField Private Methods

- (void)setup {
    
    self.placeHolderColor = [UIColor lightGrayColor];
    self.placeHolderHighlightColor = [UIColor greenColor];
    self.placeHolderErrorColor = [UIColor redColor];
    
    [self.layer addSublayer:self.borderLayer];
    
    [self addSubview:self.tipsIV];
    [self addSubview:self.placeHolderIV];
    [self addSubview:self.placeHolderL];
    [self addSubview:self.textField];
    
    self.minimumScaleFactor = .8f;
    
}


- (void)shakeAnimation {

    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = self.transform.tx;
    
    animation.delegate = self;
    animation.duration = .3f;
    animation.values = @[ @(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.borderLayer addAnimation:animation forKey:@"shake"];
    
}

- (void)minAnimation {
    
    CGFloat minWidth = self.placeHolderIV.frame.size.width * self.minimumScaleFactor + 8 + self.placeHolderL.frame.size.width * self.minimumScaleFactor + 20;
    _percent = minWidth/(self.frame.size.width*2);

    CGFloat SS,SE,SSE,SEE;
    SS = SE = .1f + _percent;
    
    SEE = .1f;
    SSE = .1f + _percent * 2;
    
    self.borderLayer.start = SSE;
    self.borderLayer.end = SEE;
    CABasicAnimation *startAnim = [CABasicAnimation animationWithKeyPath:@"start"];
    startAnim.fromValue = @(SS);
    startAnim.toValue = @(SSE);
    startAnim.duration = .3f;
    
    CABasicAnimation *endAnim = [CABasicAnimation animationWithKeyPath:@"end"];
    endAnim.fromValue = @(SE);
    endAnim.toValue = @(SEE);
    endAnim.duration = .3f;
    
    [self.borderLayer addAnimation:startAnim forKey:@"start"];
    [self.borderLayer addAnimation:endAnim forKey:@"end"];
    
    [UIView animateWithDuration:.5f animations:^{
        self.placeHolderL.transform = CGAffineTransformMakeScale(self.minimumScaleFactor, self.minimumScaleFactor);
        self.placeHolderIV.transform = CGAffineTransformMakeScale(self.minimumScaleFactor, self.minimumScaleFactor);
        [self updatePlaceHolderCenter:CGPointMake(self.frame.size.width * .1f + 10 + self.placeHolderIV.frame.size.width*self.minimumScaleFactor/2, 0)];
    } completion:nil];
}

- (void)maxAnimation {

    CABasicAnimation *startAnim = [CABasicAnimation animationWithKeyPath:@"start"];
    startAnim.fromValue = @(.1f+2*_percent);
    startAnim.toValue = @(.1f+_percent);
    startAnim.duration = .3f;
    
    CABasicAnimation *endAnim = [CABasicAnimation animationWithKeyPath:@"end"];
    endAnim.fromValue = @(.1f);
    endAnim.toValue = @(.1f + _percent);
    endAnim.duration = .3f;

    
    [UIView animateKeyframesWithDuration:.3f delay:.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.placeHolderL.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.placeHolderIV.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [self updatePlaceHolderCenter:CGPointMake(16 + self.placeHolderIV.frame.size.width/2, self.frame.size.height/2)];
    } completion:^(BOOL finished) {
        [self.borderLayer addAnimation:startAnim forKey:@"start"];
        [self.borderLayer addAnimation:endAnim forKey:@"end"];
        self.borderLayer.start = self.borderLayer.end = .1f + _percent;
    }];
    
}

/**
 *  更新placeHolderIV,placeHolderL的center位置
 *
 *  @param center placeHolderIV的center位置
 */
- (void)updatePlaceHolderCenter:(CGPoint)center {
    self.placeHolderIV.center = center;
    if (!self.placeHolderIV.image) {
        self.placeHolderL.center = CGPointMake(center.x + self.placeHolderL.frame.size.width/2, center.y);
    }else {
        self.placeHolderL.center = CGPointMake(center.x + self.placeHolderIV.frame.size.width/2 + 8 + self.placeHolderL.frame.size.width/2, center.y);
    }
}

#pragma mark - XMNAnimTextField Setters

- (void)setState:(XMNAnimTextFieldState)state {
    if (_state == state && state != XMNAnimTextFieldStateError) {
        return;
    }
    _state = state;
    switch (state) {
        case XMNAnimTextFieldStateNormal:
        {
            self.placeHolderIV.highlighted = NO;
            self.placeHolderL.textColor = self.placeHolderColor;
            self.borderLayer.borderColor = self.placeHolderColor.CGColor;
            [self.borderLayer setNeedsDisplay];
            self.textField.text.length == 0 ? [self maxAnimation] : 0;
        }
            break;
        case XMNAnimTextFieldStateEditing:
        {
            self.placeHolderIV.highlighted = YES;
            self.placeHolderL.textColor = self.placeHolderHighlightColor;
            self.borderLayer.borderColor = self.placeHolderHighlightColor.CGColor;
            [self.borderLayer setNeedsDisplay];
            self.textField.text.length == 0 ? [self minAnimation] : 0;
        }
            break;
        case XMNAnimTextFieldStateError:
        {
            self.placeHolderIV.highlighted = NO;
            self.placeHolderL.textColor = self.placeHolderErrorColor;
            self.borderLayer.borderColor = self.placeHolderErrorColor.CGColor;
            [self.borderLayer setNeedsDisplay];
            [self shakeAnimation];
        }
            break;
        default:
            break;
    }
}

- (void)setInputType:(XMNAnimTextFieldInputType)inputType {
    _inputType = inputType;
    switch (inputType) {
        case XMNAnimTextFieldInputTypePassword:
            self.textField.secureTextEntry = YES;
        case XMNAnimTextFieldInputTypeTips:
            self.tipsIV.hidden = NO;
            break;
        default:
            self.tipsIV.hidden = YES;
            self.textField.secureTextEntry = NO;
            break;
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    _delegate = delegate;
    self.textField.delegate = delegate;
}

- (void)setPlaceHolderIcon:(UIImage *)placeHolderIcon {
    self.placeHolderIV.image = placeHolderIcon;
    [self.placeHolderIV sizeToFit];
    [self updatePlaceHolderCenter:CGPointMake(16+self.placeHolderIV.frame.size.width/2, self.frame.size.height/2)];
}

- (void)setPlaceHolderHightlightIcon:(UIImage *)placeHolderHightlightIcon {
    _placeHolderHightlightIcon = placeHolderHightlightIcon;
    self.placeHolderIV.highlightedImage = placeHolderHightlightIcon;
}

- (void)setTipsIcon:(UIImage *)tipsIcon {
    _tipsIcon = tipsIcon;
    self.tipsIV.image = tipsIcon;
    [self.tipsIV sizeToFit];
    [self layoutIfNeeded];
}

- (void)setPlaceHolderText:(NSString *)placeHolderText {
    _placeHolderText = [placeHolderText copy];
    self.placeHolderL.text = placeHolderText;
    [self.placeHolderL sizeToFit];
    [self updatePlaceHolderCenter:CGPointMake(16+self.placeHolderIV.frame.size.width/2, self.frame.size.height/2)];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    self.placeHolderL.textColor = placeHolderColor;
}

- (void)setPlaceHolderHighlightColor:(UIColor *)placeHolderHighlightColor {
    _placeHolderHighlightColor = placeHolderHighlightColor;
    self.placeHolderL.highlightedTextColor = placeHolderHighlightColor;
}

- (void)setPlaceHolderErrorColor:(UIColor *)placeHolderErrorColor {
    _placeHolderErrorColor = placeHolderErrorColor;
}


#pragma mark - XMNAnimTextField Getters

- (_XMNBorderLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [_XMNBorderLayer layer];
        _borderLayer.frame = self.layer.bounds;
        [_borderLayer setNeedsDisplay];
    }
    return _borderLayer;
}

- (UIImageView *)placeHolderIV {
    if (!_placeHolderIV) {
        _placeHolderIV = [[UIImageView alloc] initWithFrame:CGRectMake(8, self.frame.size.height/2, 0, 0)];
    }
    return _placeHolderIV;
}

- (UILabel *)placeHolderL {
    if (!_placeHolderL) {
        _placeHolderL = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height/2, 0, 0)];
        _placeHolderL.font = [UIFont systemFontOfSize:kXMNMaxFontSize];
        _placeHolderL.textColor = [UIColor lightGrayColor];
        _placeHolderL.highlightedTextColor = [UIColor greenColor];
    }
    return _placeHolderL;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.frame = CGRectInset(self.bounds, 10, 6);
    }
    return _textField;
}

- (UIImageView *)tipsIV {
    if (!_tipsIV) {
        _tipsIV = [[UIImageView alloc] init];
        [_tipsIV setTintColor:[UIColor greenColor]];
    }
    return _tipsIV;
}

- (NSString *)text {
    return [self.textField.text copy];
}

@end
