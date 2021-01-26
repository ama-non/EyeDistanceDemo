//
//  FaceNavigationController.m
//  EyeDistanceDemo
//
//  Created by AtomXiaomi on 2020/12/8.
//

#import "FaceNavigationController.h"

@interface FaceNavigationController ()

@end

@implementation FaceNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate {
    UIViewController *vc = self.topViewController;
    if (vc != nil) {
        return  vc.shouldAutorotate;
    } else {
        return  NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.topViewController;
    if (vc != nil) {
        return  vc.supportedInterfaceOrientations;
    } else {
        return  UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.topViewController;
    if (vc != nil) {
        return  vc.preferredInterfaceOrientationForPresentation;
    } else {
        return  UIInterfaceOrientationUnknown;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *vc = self.topViewController;
    if (vc != nil) {
        return  vc.preferredStatusBarStyle;
    } else {
        return  UIStatusBarStyleDefault;
    }
}

@end
