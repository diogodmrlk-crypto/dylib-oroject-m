#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;
static UIView *fovCircleView = nil;
static float currentFov = 90.0f;
static float currentSmooth = 5.0f;

// ==========================================
// CLASSE DA JANELA (Toque e Rotação)
// ==========================================
@interface PPWindow : UIWindow
@property (nonatomic, weak) UIView *panelView;
@end

@implementation PPWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.panelView && CGRectContainsPoint(self.panelView.frame, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.rootViewController && self.rootViewController.view) {
        self.rootViewController.view.frame = self.bounds;
    }
}
@end

// ==========================================
// VIEW DO PAINEL (Layout ImGui Recriado)
// ==========================================
@interface PPPanelView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *mainPanel;
@property (nonatomic, strong) UIButton *tabAimbot;
@property (nonatomic, strong) UIButton *tabEsp;
@property (nonatomic, strong) UIButton *tabMisc;
@property (nonatomic, strong) UIView *aimbotCard;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISlider *fovSlider;
@property (nonatomic, strong) UILabel *fovLabel;
@property (nonatomic, strong) UISlider *smoothSlider;
@property (nonatomic, strong) UILabel *smoothLabel;
@end

@implementation PPPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    CGFloat pW = 360.0;
    CGFloat pH = 260.0;

    // 1. PAINEL PRINCIPAL
    self.mainPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, pH)];
    self.mainPanel.center = self.center;
    self.mainPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:0.98];
    self.mainPanel.layer.cornerRadius = 12;
    self.mainPanel.layer.borderWidth = 1.0;
    self.mainPanel.layer.borderColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
    self.mainPanel.clipsToBounds = YES;
    [self addSubview:self.mainPanel];

    // 2. CABEÇALHO
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, 40)];
    header.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.15 alpha:1];
    [self.mainPanel addSubview:header];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, pW - 50, 40)];
    title.text = @"🎯 PURPOU EXECUTOR";
    title.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1];
    title.font = [UIFont boldSystemFontOfSize:14];
    [header addSubview:title];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(pW - 40, 0, 40, 40);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    UIPanGestureRecognizer *dragPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [header addGestureRecognizer:dragPan];

    // 3. BARRA DE TABS ESQUERDA
    UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 60, pH - 40)];
    tabBar.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1];
    [self.mainPanel addSubview:tabBar];

    self.tabAimbot = [self createTabButton:CGRectMake(10, 15, 40, 40) icon:@"🎯" tag:1];
    self.tabEsp = [self createTabButton:CGRectMake(10, 65, 40, 40) icon:@"👁️" tag:2];
    self.tabMisc = [self createTabButton:CGRectMake(10, 115, 40, 40) icon:@"⚙️" tag:3];
    [tabBar addSubview:self.tabAimbot];
    [tabBar addSubview:self.tabEsp];
    [tabBar addSubview:self.tabMisc];

    // 4. CONTEÚDO DA ABA
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(70, 50, pW - 80, pH - 60)];
    content.backgroundColor = UIColor.clearColor;
    [self.mainPanel addSubview:content];

    // Card Aimbot
    self.aimbotCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW - 80, 45)];
    self.aimbotCard.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.15 alpha:1];
    self.aimbotCard.layer.cornerRadius = 8;
    [content addSubview:self.aimbotCard];

    UILabel *aimbotLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 45)];
    aimbotLbl.text = @"Habilitar Aimbot";
    aimbotLbl.textColor = UIColor.whiteColor;
    aimbotLbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [self.aimbotCard addSubview:aimbotLbl];

    self.aimbotSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(pW - 140, 7, 51, 31)];
    self.aimbotSwitch.onTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    [self.aimbotSwitch addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventValueChanged];
    [self.aimbotCard addSubview:self.aimbotSwitch];

    // Slider FOV
    self.fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 200, 20)];
    self.fovLabel.text = @"FOV: 90°";
    self.fovLabel.textColor = [UIColor lightGrayColor];
    self.fovLabel.font = [UIFont systemFontOfSize:12];
    [content addSubview:self.fovLabel];

    self.fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 85, pW - 90, 20)];
    self.fovSlider.minimumValue = 10;
    self.fovSlider.maximumValue = 360;
    self.fovSlider.value = 90;
    self.fovSlider.minimumTrackTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    self.fovSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.25 alpha:1];
    self.fovSlider.thumbTintColor = UIColor.whiteColor;
    [self.fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [content addSubview:self.fovSlider];

    // Slider Smooth
    self.smoothLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 200, 20)];
    self.smoothLabel.text = @"Suavidade: 5.0";
    self.smoothLabel.textColor = [UIColor lightGrayColor];
    self.smoothLabel.font = [UIFont systemFontOfSize:12];
    [content addSubview:self.smoothLabel];

    self.smoothSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 145, pW - 90, 20)];
    self.smoothSlider.minimumValue = 1.0;
    self.smoothSlider.maximumValue = 20.0;
    self.smoothSlider.value = 5.0;
    self.smoothSlider.minimumTrackTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    self.smoothSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.25 alpha:1];
    self.smoothSlider.thumbTintColor = UIColor.whiteColor;
    [self.smoothSlider addTarget:self action:@selector(smoothChanged:) forControlEvents:UIControlEventValueChanged];
    [content addSubview:self.smoothSlider];
}

- (UIButton *)createTabButton:(CGRect)frame icon:(NSString *)icon tag:(int)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    btn.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1];
    btn.layer.cornerRadius = 8;
    [btn setTitle:icon forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    return btn;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    self.mainPanel.center = CGPointMake(self.mainPanel.center.x + translation.x, self.mainPanel.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)toggleAimbot:(UISwitch *)sender {
    isAimbotEnabled = sender.isOn;
    
    if (isAimbotEnabled) {
        fovCircleView.hidden = NO;
        self.aimbotCard.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:0.2];
    } else {
        fovCircleView.hidden = YES;
        self.aimbotCard.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.15 alpha:1];
    }
}

- (void)fovChanged:(UISlider *)sender {
    currentFov = sender.value;
    self.fovLabel.text = [NSString stringWithFormat:@"FOV: %.0f°", currentFov];
    
    if (fovCircleView) {
        CGFloat newSize = currentFov * 2.5f;
        fovCircleView.bounds = CGRectMake(0, 0, newSize, newSize);
        CAShapeLayer *layer = (CAShapeLayer *)fovCircleView.layer.sublayers.firstObject;
        layer.path = [UIBezierPath bezierPathWithOvalInRect:fovCircleView.bounds].CGPath;
        fovCircleView.center = self.center;
    }
}

- (void)smoothChanged:(UISlider *)sender {
    currentSmooth = sender.value;
    self.smoothLabel.text = [NSString stringWithFormat:@"Suavidade: %.1f", currentSmooth];
}

- (void)closePanel {
    PPOverlayWindow.hidden = YES;
}
@end

// ==========================================
// LÓGICA DO AIMBOT
// ==========================================
static void (*orig_CameraUpdate)(void* self, void* method);
static void new_CameraUpdate(void* self, void* method) {
    orig_CameraUpdate(self, method);

    if (isAimbotEnabled) {
        // Aqui entra a matemática de puxar a mira
        // (Requer os offsets da câmera do Roblox)
    }
}

// ==========================================
// CÍRCULO FOV
// ==========================================
static void CreateFovCircle(UIView *parentView) {
    fovCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, currentFov * 2.5f, currentFov * 2.5f)];
    fovCircleView.center = parentView.center;
    fovCircleView.backgroundColor = UIColor.clearColor;
    fovCircleView.userInteractionEnabled = NO;
    fovCircleView.hidden = YES;

    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:fovCircleView.bounds].CGPath;
    circleLayer.fillColor = UIColor.clearColor.CGColor;
    circleLayer.strokeColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
    circleLayer.lineWidth = 1.0;
    [fovCircleView.layer addSublayer:circleLayer];
    [parentView addSubview:fovCircleView];
}

// ==========================================
// INICIALIZAÇÃO
// ==========================================
static void PPShowPanel(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (PPOverlayWindow) return;

        UIWindowScene *activeScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] &&
                scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (!activeScene) return;

        PPOverlayWindow = [[PPWindow alloc] initWithWindowScene:activeScene];
        PPOverlayWindow.frame = activeScene.coordinateSpace.bounds;
        PPOverlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
        PPOverlayWindow.backgroundColor = UIColor.clearColor;
        
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.clearColor;
        
        PPPanelView *panelView = [[PPPanelView alloc] initWithFrame:PPOverlayWindow.bounds];
        [vc.view addSubview:panelView];
        
        PPOverlayWindow.rootViewController = vc;
        ((PPWindow *)PPOverlayWindow).panelView = panelView.mainPanel;
        PPOverlayWindow.hidden = NO;
        [PPOverlayWindow makeKeyAndVisible];
    });
}

%ctor {
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
            object:nil queue:[NSOperationQueue mainQueue]
            usingBlock:^(__unused NSNotification *notification) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                    dispatch_get_main_queue(), ^{ 
                        PPShowPanel();
                        if (PPOverlayWindow) {
                            CreateFovCircle(PPOverlayWindow.rootViewController.view);
                        }
                    });
            }];
    }
}
