//
//  iPhoneViewController.m
//  AveryLamp2
//
//  Created by Avery Lamp on 4/8/15.
//  Copyright (c) 2015 Avery Lamp. All rights reserved.
//

#import "iPhoneViewController.h"
#import "ViewController.h"
#import "SkillsScene.h"
#import "EducationInfoViewController.h"
#import "LaunchingViewController.h"

@interface iPhoneViewController ()

@property UIImageView* backgroundImage;

@property BOOL  startUpdating;

@property CGSize screenSize;

@property UIMotionEffectGroup *foregroundEffect;
@end
@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation iPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int foregroundSensitivity = 40;
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-foregroundSensitivity);
    verticalMotionEffect.maximumRelativeValue = @(foregroundSensitivity);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-foregroundSensitivity);
    horizontalMotionEffect.maximumRelativeValue = @(foregroundSensitivity);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    self.foregroundEffect = group;

    
    // Do any additional setup after loading the view.
}

-(instancetype)initWithImage:(UIImage *)image withView:(UIView *)view andBackground:(UIImage *)backgrounImage;{
    self = [super init];
    if (self) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        //    CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGSize screenSize = CGSizeMake(screenBounds.size.width , screenBounds.size.height);
        self.screenSize = screenSize;
        self.image = image;
        self.view= view;
        self.icons = [[NSMutableArray alloc]init];
        self.iPhoneImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.iPhoneImage.contentMode = UIViewContentModeScaleAspectFit;
        self.iPhoneImage.image = self.image;
        [self.view addSubview:self.iPhoneImage];
        self.screenView = [[UIView alloc]initWithFrame:CGRectMake(0.08278990644 *self.iPhoneImage.frame.size.width , 0.1503759398 * self.iPhoneImage.frame.size.height,self.iPhoneImage.frame.size.width -(2*self.iPhoneImage.frame.size.width *0.08278990644 ),self.iPhoneImage.frame.size.height - (( 0.1503759398+0.1409774436)* self.iPhoneImage.frame.size.height))];
        self.screenView.backgroundColor = [UIColor blueColor];
        self.backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.screenView.frame.size.width, self.screenView.frame.size.height)];
        self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundImage.image = backgrounImage;
        self.backgroundImage.layer.masksToBounds = YES;
        [self.screenView addSubview:self.backgroundImage];
        [self.view addSubview:self.screenView];
        
        self.splashScreen = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,  0, 0)];
        self.splashScreen.contentMode = UIViewContentModeScaleAspectFill;
        self.splashScreen.layer.masksToBounds = YES;
        [self.screenView addSubview:self.splashScreen];
        
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        displayLink.frameInterval = 1;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)setupView{
    if (self.animatingResize) {
        return;
    }
    self.iPhoneImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.screenView.frame= CGRectMake(0.08278990644 *self.iPhoneImage.frame.size.width , 0.1503759398 * self.iPhoneImage.frame.size.height,self.iPhoneImage.frame.size.width -(2*self.iPhoneImage.frame.size.width *0.08278990644 ),self.iPhoneImage.frame.size.height - (( 0.1503759398+0.1409774436)* self.iPhoneImage.frame.size.height));
    self.backgroundImage.frame = CGRectMake(0, 0, self.screenView.frame.size.width, self.screenView.frame.size.height);
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.splashScreen.frame = CGRectMake(0, 0, self.screenView.frame.size.width, self.screenView.frame.size.height);
    [self setupIcons];
}

-(void)setupIcons{
    for (int i=0;i<[self.icons count];i++) {
        CGPoint pointOfIcon = CGPointMake(self.screenView.frame.size.width*3/16 + (self.screenView.frame.size.width * 5/16 * (i%3)), self.screenView.frame.size.width*3/16 + (self.screenView.frame.size.width * 5/16 * (i/3)));
        IconButton *icon= [self.icons objectAtIndex:i];
        icon.center = pointOfIcon;
    }
    
}


-(void)addIconWithImage:(UIImage *)image Name:(NSString *)name ViewController:(UIViewController *)vc andSplashImage:(UIImage*)splashImage{
    
    IconButton *icon = [[IconButton alloc]initWithViewController:nil andIconImage:image andSplashScree:splashImage];
    [icon addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
    icon.frame = CGRectMake(0, 0, self.screenView.frame.size.width*4 /16, self.screenView.frame.size.width*4 /16);
    icon.imageView.layer.cornerRadius = 0.15625 * icon.frame.size.width;
    icon.layer.cornerRadius = 0.15625 * icon.frame.size.width;
//    icon.bounds = CGRectMake( icon.bounds.origin.x,icon.bounds.origin.y, icon.bounds.size.width, icon.bounds.size.height + 15);
//    icon.clipsToBounds= YES;
    icon.name = name;
    [icon refreshNameLabel];

//      icon.clipsToBounds= YES;
//    icon.layer.masksToBounds = YES;
    
    //    NSLog(@"%f x %f , r %f ",self.screenView.frame.size.width*4.0 /16.0,self.screenView.frame.size.width*4.0 /16.0,0.15625 * icon.frame.size.width);
    [self.screenView addSubview:icon];
    [self.icons addObject:icon];
    
    [self.splashScreen removeFromSuperview];
    [self.screenView addSubview:self.splashScreen];
}

-(void)iconClicked:(IconButton *)icon{
    if (self.iconClicked) {
        return;
    }else{
        self.iconClicked = YES;
    }
    self.swipeLocked = YES;
    self.clickedIcon = icon;
    self.splashScreen.image = icon.splashScreen;
//    self.splashScreen.backgroundColor = [UIColor grayColor];
    self.splashScreen.hidden = NO;
    self.splashScreen.frame = CGRectMake(self.screenView.frame.size.width /2, self.screenView.frame.size.height /2, 0, 0);
    [UIView animateWithDuration:1.0 animations:^{
        self.splashScreen.frame = CGRectMake(0, 0, self.screenView.frame.size.width, self.screenView.frame.size.height);
    } completion:^(BOOL finished) {
        self.startUpdating = YES;
        [self.delegate iconClicked:self];
    }];
    
}

/*
-(void)openVC{
    LaunchingViewController *vc;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([self.clickedIcon.name isEqualToString:@"Education"]) {
        vc = [[EducationInfoViewController alloc]init];
        vc.mainVC = self.mainVC;
    }
    
    if ([self.clickedIcon.name isEqualToString:@"Skills"]) {
        ViewController *sceneVC = (ViewController*)vc;
        SKView *skView;
        if (![self.view viewWithTag:12534]) {
            skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            skView.tag = 12534;
            skView.backgroundColor = [UIColor whiteColor];
//            [self.mainVC.view addSubview:skView];
        }
        if ([self.clickedIcon.name isEqualToString:@"Skills"]) {
            SkillsScene *scene = [SkillsScene unarchiveFromFile:@"MyScene"];
            scene.VC = sceneVC;
            scene.backgroundColor = [UIColor whiteColor];
            scene.iPhoneVC = self;
            sceneVC.scene = scene;
            sceneVC.view = skView;
            
        }
    }
    
    [self.mainVC presentViewController:vc animated:YES completion:^{
        self.iconClicked= NO;
        self.swipeLocked = NO;
    }];
}
*/

-(void)deallocAllVCsInIcons{
    for (IconButton *b in self.icons) {
        if ([b.viewControllerToLaunch isKindOfClass:[UIViewController class]]) {
            NSLog(@"VC Deallocated");
        }
        b.viewControllerToLaunch = nil;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)update{
    if (self.startUpdating) {
        [self setupView];
    }
    
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




@end

#pragma mark - SKScene
