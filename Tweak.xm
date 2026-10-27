#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;
static UIView *fovCircleView = nil;

@interface PPPanelViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *card;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *aimbotBtn;
@property (nonatomic, strong) UIView *fovSliderBg;
@property (nonatomic, strong) UIView *fovSliderThumb;
@end

@implementation PPPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;

    // 1. PAINEL PRINCIPAL (Arrastável)
    self.card = [UIView new];
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    self.card.backgroundColor = [UIColor colorWithRed:0.06 green:0.04 blue:0.10 alpha:0.95];
    self.card.layer.cornerRadius = 16;
    self.card.layer.borderWidth = 1.5;
    self.card.layer.borderColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1].CGColor;
    self.card.layer.shadowColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1].CGColor;
    self.card.layer.shadowRadius = 12;
    self.card.layer.shadowOpacity = 0.6;
    [self.view addSubview:self.card];

    // Gesto de arrastar APENAS no topo do painel pra não bugar os botões
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.card addGestureRecognizer:pan];

    // 2. CABEÇALHO
    self.header = [UIView new];
    self.header.translatesAutoresizingMaskIntoConstraints = NO;
    self.header.backgroundColor = [UIColor colorWithRed:0.15 green:0.05 blue:0.25 alpha:1];
    self.header.layer.cornerRadius = 12;
    self.header.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.card addSubview:self.header];

    UILabel *title = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:12 weight:UIFontWeightHeavy];
    title.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:title];

    // 3. BOTÃO AIMBOT
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.aimbotBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.aimbotBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.08 blue:0.25 alpha:1];
    self.aimbotBtn.layer.cornerRadius = 10;
    self.aimbotBtn.layer.borderWidth = 1;
    self.aimbotBtn.layer.borderColor = [UIColor colorWithRed:0.43 green:0.16 blue:0.72 alpha:1].CGColor;
    [self.aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    [self.aimbotBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
    self.aimbotBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [self.aimbotBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:self.aimbotBtn];

    // 4. SLIDER DE FOV (Visual apenas por enquanto)
    UILabel *fovTitle = [UILabel new];
    fovTitle.translatesAutoresizingMaskIntoConstraints = NO;
    fovTitle.text = @"FOV: 90°";
    fovTitle.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    fovTitle.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    fovTitle.tag = 999;
    [self.card addSubview:fovTitle];

    self.fovSliderBg = [UIView new];
    self.fovSliderBg.translatesAutoresizingMaskIntoConstraints = NO;
    self.fovSliderBg.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    self.fovSliderBg.layer.cornerRadius = 3;
    [self.card addSubview:self.fovSliderBg];

    self.fovSliderThumb = [UIView new];
    self.fovSliderThumb.translatesAutoresizingMaskIntoConstraints = NO;
    self.fovSliderThumb.backgroundColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1];
    self.fovSliderThumb.layer.cornerRadius = 6;
    [self.fovSliderBg addSubview:self.fovSliderThumb];

    [NSLayoutConstraint activateConstraints:@[
        // Painel
        [self.card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.card.widthAnchor constraintEqualToConstant:220],
        [self.card.heightAnchor constraintEqualToConstant:160],

        // Header
        [self.header.topAnchor constraintEqualToAnchor:self.card.topAnchor],
        [self.header.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor],
        [self.header.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor],
        [self.header.heightAnchor constraintEqualToConstant:36],

        [title.centerXAnchor constraintEqualToAnchor:self.header.centerXAnchor],
        [title.centerYAnchor constraintEqualToAnchor:self.header.centerYAnchor],

        // Botão Aimbot
        [self.aimbotBtn.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:15],
        [self.aimbotBtn.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:15],
        [self.aimbotBtn.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-15],
        [self.aimbotBtn.heightAnchor constraintEqualToConstant:40],

        // Slider FOV
        [fovTitle.topAnchor constraintEqualToAnchor:self.aimbotBtn.bottomAnchor constant:15],
        [fovTitle.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:20],

        [self.fovSliderBg.topAnchor constraintEqualToAnchor:fovTitle.bottomAnchor constant:8],
        [self.fovSliderBg.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:20],
        [self.fovSliderBg.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-20],
        [self.fovSliderBg.heightAnchor constraintEqualToConstant:6],

        [self.fovSliderThumb.centerYAnchor constraintEqualToAnchor:self.fovSliderBg.centerYAnchor],
        [self.fovSliderThumb.leadingAnchor constraintEqualToAnchor:self.fovSliderBg.leadingAnchor constant:10],
        [self.fovSliderThumb.widthAnchor constraintEqualToConstant:12],
        [self.fovSliderThumb.heightAnchor constraintEqualToConstant:12],
    ]];

    // 5. CÍRCULO DE FOV (Fica no centro da tela, invisível por padrão)
    fovCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    fovCircleView.center = self.view.center;
    fovCircleView.backgroundColor = UIColor.clearColor;
    fovCircleView.userInteractionEnabled = NO;
    fovCircleView.hidden = YES;

    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)].CGPath;
    circleLayer.fillColor = UIColor.clearColor.CGColor;
    circleLayer.strokeColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1].CGColor;
    circleLayer.lineWidth = 1.5;
    [fovCircleView.layer addSublayer:circleLayer];

    [self.view addSubview:fovCircleView];
}

// Libera o toque pra janela de baixo (deixa o jogo rodar normal)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // Se o toque for fora do painel, ignora (passa pro jogo)
    if (hitView == self.view) {
        return nil; 
    }
    return hitView;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)toggleAimbot:(UIButton *)sender {
    isAimbotEnabled = !isAimbotEnabled;
    
    if (isAimbotEnabled) {
        [sender setTitle:@"Aimbot: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.43 green:0.16 blue:0.72 alpha:1];
        [sender setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        fovCircleView.hidden = NO;
    } else {
        [sender setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.15 green:0.08 blue:0.25 alpha:1];
        [sender setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
        fovCircleView.hidden = YES;
    }
}
@end

static void PPShowPanel(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (PPOverlayWindow && !PPOverlayWindow.hidden) return;

        UIWindowScene *activeScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] &&
                scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (!activeScene) return;

        if (!PPOverlayWindow) {
            PPOverlayWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
            PPOverlayWindow.frame = activeScene.coordinateSpace.bounds;
            // MUDANÇA AQUI: Nível abaixo do alerta pra não travar o jogo
            PPOverlayWindow.windowLevel = UIWindowLevelNormal + 1; 
            PPOverlayWindow.backgroundColor = UIColor.clearColor;
            PPOverlayWindow.rootViewController = [PPPanelViewController new];
            
            // Impede que a janela capture os toques gerais
            PPOverlayWindow.userInteractionEnabled = YES;
        }
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
                    dispatch_get_main_queue(), ^{ PPShowPanel(); });
            }];
    }
}
