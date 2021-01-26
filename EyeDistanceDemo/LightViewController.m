//
//  LightViewController.m
//  EyeDistanceDemo
//
//  Created by AtomXiaomi on 2020/12/11.
//

#import "LightViewController.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface LightViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UILabel *lightLabel;

@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureSession = [[AVCaptureSession alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = [UIColor redColor];
    self.cameraView = [UIView new];
    self.cameraView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.cameraView.center = self.view.center;
    self.cameraView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.lightLabel];
    [self.lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-200);
    }];
    
    [self setupCapture];
    [self.captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.captureSession stopRunning];
}

- (void)setupCapture {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    [device lockForConfiguration:nil];
    [self.captureSession commitConfiguration];
    [device unlockForConfiguration];
    
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    [self.captureSession addInput:input];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    self.previewLayer.videoGravity = kCAGravityResizeAspect;
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL)];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedLong:kCVPixelFormatType_32BGRA]};
    [self.captureSession addOutput:output];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lightLabel.text = [NSString stringWithFormat:@"brightness = %.4f", brightnessValue];
    });
}

#pragma mark - getter

- (UILabel *)lightLabel {
    if (!_lightLabel) {
        _lightLabel = [UILabel new];
        _lightLabel.font = [UIFont systemFontOfSize:18];
        _lightLabel.backgroundColor = [UIColor blackColor];
        _lightLabel.textColor = [UIColor whiteColor];
        _lightLabel.numberOfLines = 0;
        [_lightLabel sizeToFit];
    }
    
    return _lightLabel;
}

@end
