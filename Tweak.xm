#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;
static UIView *fovCircleView = nil;

// ==========================================
// CLASSE DA JANELA (Para girar a tela)
// ==========================================
@interface PPWindow : UIWindow
@property (nonatomic, weak) UIView *panelView;
@end

@implementation PPWindow
// Isso garante que o toque fora do painel vá pro Roblox
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.panelView && CGRectContainsPoint(self.panelView.frame, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

// Isso força a janela a girar quando o celular deita
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.rootViewController && self.rootViewController.view) {
        self.rootViewController.view.frame = self.bounds;
    }
}
@end

// ==========================================
// VIEW DO PAINEL
// ==========================================
@interface PPPanelView : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIButton *aimbotBtn;
@property (nonatomic, strong) UIView *toggleThumb;
@property (nonatomic, assign) BOOL isAimbotEnabled;
@end

@implementation PPPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.isAimbotEnabled = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    CGFloat pW = 260.0;
    CGFloat pH = 180.0;

    // 1. PAINEL PRINCIPAL (Estilo Vermelho/Preto)
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, pH)];
    self.panel.center = self.center;
    self.panel.backgroundColor = [UIColor colorWithRed:0.04 green:0.02 blue:0.06 alpha:0.98];
    self.panel.layer.cornerRadius = 12;
    self.panel.layer.borderWidth = 1.5;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
    self.panel.clipsToBounds = YES;
    [self addSubview:self.panel];

    // 2. CABEÇALHO VERMELHO
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, 35)];
    header.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    [self.panel addSubview:header];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pW, 35)];
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:13];
    title.textAlignment = NSTextAlignmentCenter;
    [header addSubview:title];

    // Botão X
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(pW - 35, 0, 35, 35);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    // Arrastar no cabeçalho
    UIPanGestureRecognizer *dragPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [header addGestureRecognizer:dragPan];

    // 3. BOTÃO AIMBOT (RETANGULAR ESTILO MENU)
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(15, 50, pW - 30, 110)];
    content.backgroundColor = [UIColor clearColor];
    [self.panel addSubview:content];

    // Fundo do botão Aimbot (Card escuro)
    UIView *aimbotCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW - 30, 45)];
    aimbotCard.backgroundColor = [UIColor colorWithRed:0.1 green:0.05 blue:0.15 alpha:1];
    aimbotCard.layer.cornerRadius = 8;
    aimbotCard.layer.borderWidth = 1;
    aimbotCard.layer.borderColor = [UIColor colorWithRed:0.3 green:0.1 blue:0.4 alpha:1].CGColor;
    [content addSubview:aimbotCard];

    // Ícone Quadrado Vermelho
    UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    iconBox.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    iconBox.layer.cornerRadius = 4;
    [aimbotCard addSubview:iconBox];
    
    UILabel *iconTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    iconTxt.text = @"🎯";
    iconTxt.font = [UIFont systemFontOfSize:14];
    iconTxt.textAlignment = NSTextAlignmentCenter;
    [iconBox addSubview:iconTxt];

    // Texto Aimbot
    UILabel *aimbotLbl = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 100, 25)];
    aimbotLbl.text = @"Aimbot";
    aimbotLbl.textColor = UIColor.whiteColor;
    aimbotLbl.font = [UIFont boldSystemFontOfSize:13];
    [aimbotCard addSubview:aimbotLbl];

    // BOTÃO TOGGLE (Switch)
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aimbotBtn.frame = CGRectMake(pW - 85, 8, 50, 28);
    self.aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.aimbotBtn.layer.cornerRadius = 14;
    self.aimbotBtn.layer.borderWidth = 1;
    self.aimbotBtn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
    [self.aimbotBtn addTarget:self action:@selector(toggleAimbot) forControlEvents:UIControlEventTouchUpInside];
    [aimbotCard addSubview:self.aimbotBtn];

    // Bolinha do Toggle
    self.toggleThumb = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 24, 24)];
    self.toggleThumb.backgroundColor = UIColor.whiteColor;
    self.toggleThumb.layer.cornerRadius = 12;
    [self.aimbotBtn addSubview:self.toggleThumb];

    // 4. SLIDER FOV (Estilo ImGui do teu print)
    UILabel *fovLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 20)];
    fovLbl.text = @"FOV: 90";
    fovLbl.textColor = UIColor.lightGrayColor;
    fovLbl.font = [UIFont systemFontOfSize:12];
    [content addSubview:fovLbl];

    UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 80, pW - 50, 20)];
    fovSlider.minimumValue = 10;
    fovSlider.maximumValue = 360;
    fovSlider.value = 90;
    fovSlider.minimumTrackTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1]; // Vermelho
    fovSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.3 alpha:1];
    fovSlider.thumbTintColor = UIColor.whiteColor;
    [fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [content addSubview:fovSlider];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    self.panel.center = CGPointMake(self.panel.center.x + translation.x, self.panel.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)toggleAimbot {
    self.isAimbotEnabled = !self.isAimbotEnabled;
    BOOL isEnabled = self.isAimbotEnabled;
    UIButton *btn = self.aimbotBtn;
    UIView *thumb = self.toggleThumb;
    
    [UIView animateWithDuration:0.2 animations:^{
        if (isEnabled) {
            btn.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
            thumb.frame = CGRectMake(24, 2, 24, 24);
            fovCircleView.hidden = NO; // LIGA O CÍRCULO DE FOV
        } else {
            btn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
            thumb.frame = CGRectMake(2, 2, 24, 24);
            fovCircleView.hidden = YES; // DESLIGA O CÍRCULO DE FOV
        }
    }];
}

- (void)fovChanged:(UISlider *)sender {
    // Aqui tu pode atualizar o texto do FOV
}

- (void)closePanel {
    PPOverlayWindow.hidden = YES;
}
@end

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
        ((PPWindow *)PPOverlayWindow).panelView = panelView;
        PPOverlayWindow.hidden = NO;
        [PPOverlayWindow makeKeyAndVisible];
    });
}

// CÍRCULO DE FOV FINO
static void CreateFovCircle(UIView *parentView) {
    fovCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    fovCircleView.center = parentView.center;
    fovCircleView.backgroundColor = UIColor.clearColor;
    fovCircleView.userInteractionEnabled = NO;
    fovCircleView.hidden = YES;

    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)].CGPath;
    circleLayer.fillColor = UIColor.clearColor.CGColor;
    circleLayer.strokeColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
    circleLayer.lineWidth = 1.0;
    [fovCircleView.layer addSublayer:circleLayer];
    [parentView addSubview:fovCircleView];
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
