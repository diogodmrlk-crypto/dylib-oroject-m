#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;
static UIView *fovCircleView = nil;

@interface PPPanelViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *card;
@property (nonatomic, strong) UIButton *aimbotBtn;
@property (nonatomic, strong) UISlider *fovSlider;
@property (nonatomic, strong) UILabel *fovLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation PPPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;

    // ==========================================
    // 1. O PAINEL PRINCIPAL (QUADRADO E ESTILIZADO)
    // ==========================================
    self.card = [UIView new];
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    // Fundo escuro semi-transparente com borda vermelha (baseado na sua 2ª foto)
    self.card.backgroundColor = [UIColor colorWithRed:0.05 green:0.02 blue:0.08 alpha:0.95];
    self.card.layer.cornerRadius = 4; // Quadrado, canto levemente arredondado
    self.card.layer.borderWidth = 1.5;
    self.card.layer.borderColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor; // Borda Vermelha
    [self.view addSubview:self.card];

    // ==========================================
    // 2. CABEÇALHO
    // ==========================================
    UIView *header = [UIView new];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    [self.card addSubview:header];

    UILabel *title = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    title.textAlignment = NSTextAlignmentCenter;
    [header addSubview:title];
    
    // Botão de fechar
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    // ==========================================
    // 3. CONTAINER (Área dos controles)
    // ==========================================
    UIView *contentBox = [UIView new];
    contentBox.translatesAutoresizingMaskIntoConstraints = NO;
    contentBox.backgroundColor = [UIColor colorWithRed:0.08 green:0.04 blue:0.12 alpha:1];
    [self.card addSubview:contentBox];

    // BOTÃO DO AIMBOT
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.aimbotBtn.translatesAutoresizingMaskIntoConstraints = NO;
    // Cor inicial (desligado)
    self.aimbotBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.05 blue:0.2 alpha:1];
    self.aimbotBtn.layer.cornerRadius = 4;
    self.aimbotBtn.layer.borderWidth = 1;
    self.aimbotBtn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
    [self.aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    [self.aimbotBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    self.aimbotBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self.aimbotBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
    [contentBox addSubview:self.aimbotBtn];

    // LABEL DO FOV
    self.fovLabel = [UILabel new];
    self.fovLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.fovLabel.text = @"FOV: 90";
    self.fovLabel.textColor = UIColor.whiteColor;
    self.fovLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [contentBox addSubview:self.fovLabel];

    // SLIDER DO FOV
    self.fovSlider = [UISlider new];
    self.fovSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.fovSlider.minimumValue = 10;
    self.fovSlider.maximumValue = 360;
    self.fovSlider.value = 90;
    self.fovSlider.minimumTrackTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1]; // Vermelho
    self.fovSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.fovSlider.thumbTintColor = UIColor.whiteColor;
    [self.fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [contentBox addSubview:self.fovSlider];

    // ==========================================
    // 4. GESTOS
    // ==========================================
    // Arrastar só funciona na área do cabeçalho (pra não bugar o slider)
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [header addGestureRecognizer:self.panGesture];

    // ==========================================
    // 5. LAYOUT (TUDO QUADRADO)
    // ==========================================
    [NSLayoutConstraint activateConstraints:@[
        // Painel principal fixo em um quadrado de 200x160
        [self.card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.card.widthAnchor constraintEqualToConstant:200],
        [self.card.heightAnchor constraintEqualToConstant:150],

        // Header
        [header.topAnchor constraintEqualToAnchor:self.card.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:28],

        [title.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [title.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        
        [closeBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [closeBtn.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-8],
        [closeBtn.widthAnchor constraintEqualToConstant:20],
        [closeBtn.heightAnchor constraintEqualToConstant:20],

        // Content Box
        [contentBox.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:10],
        [contentBox.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:10],
        [contentBox.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-10],
        [contentBox.bottomAnchor constraintEqualToAnchor:self.card.bottomAnchor constant:-10],

        // Botão Aimbot
        [self.aimbotBtn.topAnchor constraintEqualToAnchor:contentBox.topAnchor constant:5],
        [self.aimbotBtn.leadingAnchor constraintEqualToAnchor:contentBox.leadingAnchor],
        [self.aimbotBtn.trailingAnchor constraintEqualToAnchor:contentBox.trailingAnchor],
        [self.aimbotBtn.heightAnchor constraintEqualToConstant:32],

        // FOV Label
        [self.fovLabel.topAnchor constraintEqualToAnchor:self.aimbotBtn.bottomAnchor constant:12],
        [self.fovLabel.leadingAnchor constraintEqualToAnchor:contentBox.leadingAnchor],

        // Slider
        [self.fovSlider.topAnchor constraintEqualToAnchor:self.fovLabel.bottomAnchor constant:2],
        [self.fovSlider.leadingAnchor constraintEqualToAnchor:contentBox.leadingAnchor],
        [self.fovSlider.trailingAnchor constraintEqualToAnchor:contentBox.trailingAnchor],
    ]];

    // ==========================================
    // 6. CÍRCULO DE FOV FINO
    // ==========================================
    fovCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    fovCircleView.center = self.view.center;
    fovCircleView.backgroundColor = UIColor.clearColor;
    fovCircleView.userInteractionEnabled = NO;
    fovCircleView.hidden = YES;

    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)].CGPath;
    circleLayer.fillColor = UIColor.clearColor.CGColor;
    circleLayer.strokeColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor; // Vermelho fino
    circleLayer.lineWidth = 1.0;
    [fovCircleView.layer addSublayer:circleLayer];

    [self.view addSubview:fovCircleView];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    self.card.center = CGPointMake(self.card.center.x + translation.x,
                                   self.card.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)toggleAimbot:(UIButton *)sender {
    isAimbotEnabled = !isAimbotEnabled;
    
    if (isAimbotEnabled) {
        [sender setTitle:@"Aimbot: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1]; // Vermelho ligado
        sender.layer.borderColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
        [sender setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        fovCircleView.hidden = NO;
    } else {
        [sender setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.15 green:0.05 blue:0.2 alpha:1]; // Desligado
        sender.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
        [sender setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
        fovCircleView.hidden = YES;
    }
}

- (void)fovChanged:(UISlider *)sender {
    self.fovLabel.text = [NSString stringWithFormat:@"FOV: %.0f", sender.value];
    
    // Atualiza o tamanho do círculo na tela
    CGFloat newSize = sender.value * 1.5; // Multiplicador pra ficar visível
    fovCircleView.bounds = CGRectMake(0, 0, newSize, newSize);
    
    // Redesenha o círculo
    CAShapeLayer *circleLayer = (CAShapeLayer *)fovCircleView.layer.sublayers.firstObject;
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:fovCircleView.bounds].CGPath;
    fovCircleView.center = self.view.center; // Mantém centralizado
}

- (void)closeTapped {
    PPOverlayWindow.hidden = YES;
}
@end

// ==========================================
// JANELA QUE IGNORA CLIQUES FORA DO PAINEL
// ==========================================
@interface PPOverlayWindowClass : UIWindow
@property (nonatomic, weak) UIView *menuView;
@end

@implementation PPOverlayWindowClass

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // Se o toque tá DENTRO do painel, deixa clicar nos botões
    if (self.menuView && CGRectContainsPoint(self.menuView.frame, point)) {
        return hitView;
    }
    
    // Se o toque foi FORA, o jogo recebe
    return nil;
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
            PPOverlayWindow = [[PPOverlayWindowClass alloc] initWithWindowScene:activeScene];
            PPOverlayWindow.frame = activeScene.coordinateSpace.bounds;
            PPOverlayWindow.windowLevel = UIWindowLevelNormal + 1;
            PPOverlayWindow.backgroundColor = UIColor.clearColor;
            
            PPPanelViewController *vc = [PPPanelViewController new];
            PPOverlayWindow.rootViewController = vc;
            
            ((PPOverlayWindowClass *)PPOverlayWindow).menuView = vc.card;
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
