//
//  SNKeyboardScrollView.m
//  SNKeyboardScrollView
//
//  Created by 王少刚 on 2017/6/7.
//  Copyright © 2017年 Shawn. All rights reserved.
//

#import "SNKeyboardScrollView.h"

@interface SNKeyboardScrollView(){
    CGFloat _distance;
}

@end

@implementation SNKeyboardScrollView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)initial{
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.contentSize = self.bounds.size;
    CGSize rect      = self.contentSize;
    rect.height     += 1;
    self.contentSize = rect;
    
    [self registNotification];
}

- (void)registNotification{
    
    // 注册键盘监听
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification{
    
    NSDictionary *dict  = notification.userInfo;
    CGRect keyboardRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UITextField *firstResponder = [self findFirstResponder:self];
    
    // nil默认代表的是当前的window上的位置
    CGRect firstResponderRect = [firstResponder convertRect:firstResponder.bounds toView:nil];
    CGFloat distance = firstResponderRect.origin.y + firstResponderRect.size.height - keyboardRect.origin.y;
    _distance = distance;
    
    // 键盘遮挡
    if (distance > 0) {
        //滚动到当前文本框
        [self animationWithUserInfo:notification.userInfo block:^{
            CGPoint offset = self.contentOffset;
            offset.y      += distance;
            self.contentOffset = offset;
        }];
    } else {
        _distance = 0;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    
    [self animationWithUserInfo:notification.userInfo block:^{
        CGPoint offset = self.contentOffset;
        offset.y      -= _distance;
        self.contentOffset = offset;
        _distance = 0;
    }];
}

#pragma mark - touche
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self endEditing:YES];
//}

#pragma mark - Private
#pragma mark 键盘弹出和隐藏的时候改变视图要执行的动画
- (void)animationWithUserInfo:(NSDictionary *)userInfo block:(void(^)(void)) block
{
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    block();
    [UIView commitAnimations];
}

/**
 查找第一响应者 递归
 
 @param view self
 @return view
 */
- (UITextField *)findFirstResponder:(UIView *)view{
    
    for(UIView *child in view.subviews) {
        // 当前 subviews
        if ([child respondsToSelector:@selector(isFirstResponder)] && [child isFirstResponder]) {
            return (UITextField *)child;
        }
        // 上一层的subviews
        UITextField *textField = [self findFirstResponder:child];
        if (textField) {
            return textField;
        }
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
