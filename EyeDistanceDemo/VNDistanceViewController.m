//
//  VNDistanceViewController.m
//  EyeDistanceDemo
//
//  Created by AtomXiaomi on 2020/12/4.
//

#import "VNDistanceViewController.h"
#import <Vision/Vision.h>
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>

API_AVAILABLE(ios(11.0))
@interface VNDistanceViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, assign) float fLength;
@property (nonatomic, assign) CGRect clap;
@property (nonatomic, assign) float eyeDistance;
@property (nonatomic, assign) CGFloat upScale;
@property (nonatomic, assign) float hrsiFactor;
@property (nonatomic, assign) float hrsiHeight;
@property (nonatomic, assign) float fovFactor;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIView *faceRectLayer;
@property (nonatomic, strong) UILabel *distanceLabel;

@end

API_AVAILABLE(ios(11.0))
@implementation VNDistanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.clap = CGRectZero;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = [UIColor redColor];
    self.cameraView = [UIView new];
    self.cameraView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.cameraView.center = self.view.center;
    self.cameraView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.cameraView];
    self.faceRectLayer =  [UIView new];
    [self.cameraView addSubview:self.faceRectLayer];
    [self.view addSubview:self.distanceLabel];
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.fLength = [self getEquivalentFocalLength:device.activeFormat];
    [self.captureSession addInput:input];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    self.previewLayer.videoGravity = kCAGravityResizeAspect;
    self.faceRectLayer.layer.borderColor = UIColor.blueColor.CGColor;
    self.faceRectLayer.layer.borderWidth = 3.0;
    self.faceRectLayer.backgroundColor = UIColor.clearColor;
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL)];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedLong:kCVPixelFormatType_32BGRA]};
    [self.captureSession addOutput:output];
    
    [self.cameraView bringSubviewToFront:self.faceRectLayer];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (buffer == nil) {
        NSLog(@"NO Buffer");
        return;
    }
    
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (fdesc != nil) {
        self.clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, YES);
        self.hrsiFactor = (float)self.clap.size.height / self.hrsiHeight;
    }
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:buffer orientation:kCGImagePropertyOrientationDownMirrored options:@{}];
    
    VNDetectFaceLandmarksRequest *faceRequest = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        NSArray *results = request.results;
        [self processLandmarks:results];
    }];
    
    [handler performRequests:@[faceRequest] error:nil];
}

- (void)processLandmarks:(NSArray<VNFaceObservation *> *)faces  API_AVAILABLE(ios(11.0)){
    if (faces.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.distanceLabel.text = @"NO FACE";
        });
        return;
    }
    
    // 面部
    VNFaceObservation *firstFace = [faces firstObject];
    CGRect faceBoxOnScreen = [self.previewLayer rectForMetadataOutputRectOfInterest:firstFace.boundingBox];
    
    CGFloat x = faceBoxOnScreen.origin.x;
    CGFloat y = faceBoxOnScreen.origin.y;
    CGFloat w = faceBoxOnScreen.size.width;
    CGFloat h = faceBoxOnScreen.size.height;
    
    // 左眼球
    VNFaceLandmarkRegion2D *leftPupil = firstFace.landmarks.leftPupil;
    // 右眼球
    VNFaceLandmarkRegion2D *rightPupil = firstFace.landmarks.rightPupil;
    
    if (![leftPupil isEqual:[NSNull null]] && ![rightPupil isEqual:[NSNull null]]) {
        const CGPoint *leftEyePoint = leftPupil.normalizedPoints;
        const CGPoint *rightEyePoint = rightPupil.normalizedPoints;
        
        // 标准化处理
        CGFloat leftX = leftEyePoint->x * w + x;
        CGFloat rightX = rightEyePoint->x * w + x;
        
        CGFloat leftY = leftEyePoint->y * h + y;
        CGFloat rightY = rightEyePoint->y * h + y;
        
        self.eyeDistance = sqrtf(powf((float)(leftX - rightX), 2) + powf((float)(leftY - rightY), 2));
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.cameraView.subviews) {
            [view removeFromSuperview];
        }
        self.faceRectLayer.frame = faceBoxOnScreen;
        [self.cameraView addSubview:self.faceRectLayer];
        
        float upScaleFactor = (float)((CGFloat)self.hrsiHeight / self.upScale / self.clap.size.height);
        
        float distanceAli = (1.0 + 63 * (float)self.previewLayer.frame.size.width / 24 / self.eyeDistance) * self.fLength / 10.0 * (float)self.upScale * self.hrsiFactor * self.fovFactor * upScaleFactor;
        self.distanceLabel.text = [NSString stringWithFormat:@"distance = %f CM", distanceAli];
    });
}

- (float)getEquivalentFocalLength:(AVCaptureDeviceFormat *)format {
    // 转换为弧度
    self.upScale  = format.videoZoomFactorUpscaleThreshold;
    float fov = format.videoFieldOfView * (float)M_PI / 180.0;
    self.fovFactor = 67.564 / format.videoFieldOfView;
    
    // 角和直角三角形的对角分别是 fov的一半和宽度的一半
    // 35毫米胶片（即18毫米），直角三角形的相邻值等于焦距
//    float focalLen = 20.85 / tan(fov/2);
    float focalLen = 15.5 / tan(fov/2);
    self.hrsiHeight = (float)(format.highResolutionStillImageDimensions.height);
    
    return focalLen;
}

#pragma mark - getter

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [UILabel new];
        _distanceLabel.font = [UIFont systemFontOfSize:18];
        _distanceLabel.backgroundColor = [UIColor blackColor];
        _distanceLabel.textColor = [UIColor whiteColor];
        _distanceLabel.numberOfLines = 0;
        [_distanceLabel sizeToFit];
    }
    
    return _distanceLabel;
}

#pragma mark - 方向控制

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

