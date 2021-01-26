//
//  ViewController.m
//  EyeDistanceDemo
//
//  Created by AtomXiaomi on 2020/12/4.
//

#import "ViewController.h"
#import "VNDistanceViewController.h"
#import "ARDistanceViewController.h"
#import <ARKit/ARKit.h>
#import "LightViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *vnBtn;
@property (nonatomic, strong) UIButton *arBtn;
@property (nonatomic, strong) UIButton *lightBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self setupUI];
}

- (void)setupUI {
    self.vnBtn = [UIButton new];
    self.vnBtn.frame = CGRectMake(0, 0, 200, 60);
    self.vnBtn.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    self.vnBtn.layer.cornerRadius = 24;
    [self.vnBtn setTitle:@"使用Vision" forState:UIControlStateNormal];
    self.vnBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.vnBtn.layer.borderColor = UIColor.whiteColor.CGColor;
    self.vnBtn.layer.borderWidth = 1.0;
    [self.vnBtn addTarget:self action:@selector(goToVNVC) forControlEvents:UIControlEventTouchUpInside];
    self.vnBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.vnBtn];
    
    self.arBtn = [UIButton new];
    self.arBtn.frame = CGRectMake(0, 0, 200, 60);
    self.arBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
    self.arBtn.layer.cornerRadius = 24;
    [self.arBtn setTitle:@"使用ARKit" forState:UIControlStateNormal];
    self.arBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.arBtn.layer.borderColor = UIColor.whiteColor.CGColor;
    self.arBtn.layer.borderWidth = 1.0;
    [self.arBtn addTarget:self action:@selector(goToARVC) forControlEvents:UIControlEventTouchUpInside];
    self.vnBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.arBtn];
    
    self.lightBtn = [UIButton new];
    self.lightBtn.frame = CGRectMake(0, 0, 200, 60);
    self.lightBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    self.lightBtn.layer.cornerRadius = 24;
    [self.lightBtn setTitle:@"光照" forState:UIControlStateNormal];
    self.lightBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.lightBtn.layer.borderColor = UIColor.whiteColor.CGColor;
    self.lightBtn.layer.borderWidth = 1.0;
    [self.lightBtn addTarget:self action:@selector(goToLightVC) forControlEvents:UIControlEventTouchUpInside];
    self.lightBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.lightBtn];

}

- (void)goToVNVC {
    VNDistanceViewController *vc = [[VNDistanceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToARVC {
    if (ARFaceTrackingConfiguration.isSupported) {
        ARDistanceViewController *vc = [[ARDistanceViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"设备不支持ARFace" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
}

- (void)goToLightVC {
    LightViewController *vc = [[LightViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 方向控制

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

