//
//  ARDistanceViewController.m
//  EyeDistanceDemo
//
//  Created by AtomXiaomi on 2020/12/4.
//

#import "ARDistanceViewController.h"
#import <ARKit/ARKit.h>
#import <Masonry/Masonry.h>

@interface ARDistanceViewController ()<ARSCNViewDelegate>

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) SCNNode *faceNode;
@property (nonatomic, strong) SCNNode *leftEye;
@property (nonatomic, strong) SCNNode *rightEye;

@end

@implementation ARDistanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    //Set Up Face Tracking
    ARFaceTrackingConfiguration *config = [[ARFaceTrackingConfiguration alloc] init];
    config.lightEstimationEnabled = YES;
    
    [self.view addSubview:self.sceneView];
    [self.view addSubview:self.distanceLabel];
    self.sceneView.delegate = self;
    self.sceneView.showsStatistics = YES;
    [self.sceneView.session runWithConfiguration:config options:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    
    [self setupEyeNode];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
}

/// Creates To SCNSpheres To Loosely Represent The Eyes
- (void)setupEyeNode {
    //1. Create A Node To Represent The Eye
    SCNSphere *eyeGeometry = [SCNSphere sphereWithRadius:0.005];
    eyeGeometry.materials.firstObject.diffuse.contents = [UIColor greenColor];
    eyeGeometry.materials.firstObject.transparency = 1.0;
    
    //2. Create A Holder Node & Rotate It So The Gemoetry Points Towards The Device
    SCNNode *node = [SCNNode nodeWithGeometry:eyeGeometry];
    node.eulerAngles = SCNVector3Make(-M_PI_2, node.eulerAngles.y, node.eulerAngles.z);
    node.position = SCNVector3Make(node.position.x, node.position.y, 0.1);
    
    //3. Create The Left & Right Eyes
    self.leftEye = [node clone];
    self.rightEye = [node clone];
}

- (void)trackDistance {
    //4. Get The Distance Of The Eyes From The Camera
    SCNVector3 leftEyeDistanceFromCamera = [self substractSCNVector3:self.leftEye.worldPosition with:SCNVector3Zero];
    SCNVector3 rightEyeDistanceFromCamera = [self substractSCNVector3:self.rightEye.worldPosition with:SCNVector3Zero];
    
    //5. Calculate The Average Distance Of The Eyes To The Camera
    float leftDistance = [self lengthOfSCNVector3:leftEyeDistanceFromCamera];
    float rightDistance = [self lengthOfSCNVector3:rightEyeDistanceFromCamera];
    float averageDistance = (leftDistance + rightDistance) / 2;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.distanceLabel.text = [NSString stringWithFormat:@"distance = %f CM", averageDistance * 100];
    });
}

///Allow To Subtract Two SCNVector3's
- (SCNVector3)substractSCNVector3:(SCNVector3)leftNode with:(SCNVector3)rightNode {
    return SCNVector3Make(leftNode.x - rightNode.x, leftNode.y - rightNode.y, leftNode.z - rightNode.z);
}

///Get The Length Of Vector
- (float)lengthOfSCNVector3:(SCNVector3)vector {
    return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

#pragma mark - delegate

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    // setup node eye and face
    self.faceNode = node;
    
    id<MTLDevice> device = self.sceneView.device;
    if ([device isEqual:[NSNull null]]) {
        return;
    }
    ARSCNFaceGeometry *faceGeo = [ARSCNFaceGeometry faceGeometryWithDevice:device];
    self.faceNode.geometry = faceGeo;
    self.faceNode.geometry.firstMaterial.fillMode = SCNFillModeLines;
    [self.faceNode addChildNode:self.leftEye];
    [self.faceNode addChildNode:self.rightEye];
    self.faceNode.transform = node.transform;
    
    // 获取距离
    [self trackDistance];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor API_AVAILABLE(ios(12.0)){
    self.faceNode.transform = node.transform;
    self.faceNode.geometry.materials.firstObject.diffuse.contents = [UIColor yellowColor];
    ARFaceAnchor *faceAnchor = (ARFaceAnchor *)anchor;
    if ([faceAnchor isEqual:[NSNull null]]) {
        return;
    }
    
    ARSCNFaceGeometry *faceGeo = (ARSCNFaceGeometry *)node.geometry;
    if (![faceGeo isEqual:[NSNull null]]) {
        [faceGeo updateFromFaceGeometry:faceAnchor.geometry];
    }
    self.leftEye.simdTransform = faceAnchor.leftEyeTransform;
    self.rightEye.simdTransform = faceAnchor.rightEyeTransform;
    // 获取距离
    [self trackDistance];
}

#pragma mark - getter

- (ARSCNView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _sceneView.center = self.view.center;
    }
    
    return _sceneView;
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [UILabel new];
        _distanceLabel.font = [UIFont systemFontOfSize:18];
        _distanceLabel.frame = CGRectMake(100, 650, 400, 60);
        _distanceLabel.textColor = [UIColor whiteColor];
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

