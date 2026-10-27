#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;

// ==========================================
// CLASSE DA JANELA (Para não travar o jogo)
// ==========================================
@interface PPWindow : UIWindow
@end

@implementation PPWindow
// Isso garante que a janela não crie uma barreira invisível no jogo
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO; 
}
@end

// ==========================================
// VIEW DO PAINEL
// ==========================================
@interface PPPanelView : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *aimbotBtn;
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
    // 1. O PAINEL PRINCIPAL
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 140)];
    self.panel.center = self.center;
    self.panel.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:0.95];
    self.panel.layer.cornerRadius = 8;
    self.panel.layer.borderWidth = 1.5;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1].CGColor;
    self.panel.clipsToBounds = YES;
    [self addSubview:self.panel];

    // Gesto de arrastar SÓ no cabeçalho
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panel addGestureRecognizer:pan];

    // 2. CABEÇALHO VERMELHO
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    self.header.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
    [self.panel addSubview:self.header];

    // Título do Cabeçalho
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 30)];
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:11];
    title.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:title];

    // Botão X
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(230, 0, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.header addSubview:closeBtn];

    // 3. CONTAINER DA TOGGLE
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 240, 80)];
    content.backgroundColor = [UIColor clearColor];
    [self.panel addSubview:content];

    // Ícone Quadrado Vermelho (Esquerda)
    UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    iconBox.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
    iconBox.layer.cornerRadius = 4;
    [content addSubview:iconBox];
    
    UILabel *iconTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    iconTxt.text = @"🎯";
    iconTxt.font = [UIFont systemFontOfSize:14];
    iconTxt.textAlignment = NSTextAlignmentCenter;
    [iconBox addSubview:iconTxt];

    // Texto "Aimbot"
    UILabel *aimbotLbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 100, 30)];
    aimbotLbl.text = @"Aimbot";
    aimbotLbl.textColor = UIColor.whiteColor;
    aimbotLbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [content addSubview:aimbotLbl];

    // BOTÃO TOGGLE (Falso Switch)
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aimbotBtn.frame = CGRectMake(180, 12, 50, 26);
    self.aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.aimbotBtn.layer.cornerRadius = 13;
    self.aimbotBtn.layer.borderWidth = 1;
    self.aimbotBtn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
    [self.aimbotBtn addTarget:self action:@selector(toggleAimbot) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:self.aimbotBtn];

    // Bolinha do Toggle
    UIView *thumb = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 22, 22)];
    thumb.backgroundColor = UIColor.whiteColor;
    thumb.layer.cornerRadius = 11;
    thumb.tag = 101; // Tag pra achar depois
    [self.aimbotBtn addSubview:thumb];
}

// Lógica pra arrastar o painel
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    
    // Move o painel
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

// Lógica do botão Aimbot
- (void)toggleAimbot {
    isAimbotEnabled = !isAimbotEnabled;
    UIView *thumb = [self.aimbotBtn viewWithTag:101];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self->isAimbotEnabled) { // Usando self-> por causa do bloco de animação
            self.aimbotBtn.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
            self.aimbotBtn.layer.borderColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1].CGColor;
            thumb.frame = CGRectMake(26, 2, 22, 22);
        } else {
            self.aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
            self.aimbotBtn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
            thumb.frame = CGRectMake(2, 2, 22, 22);
        }
    }];
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
            // Usa a PPWindow que não bloqueia o toque
            PPOverlayWindow = [[PPWindow alloc] initWithWindowScene:activeScene];
            PPOverlayWindow.frame = activeScene.coordinateSpace.bounds;
            PPOverlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
            PPOverlayWindow.backgroundColor = UIColor.clearColor;
            
            // O Controller é vazio, a View faz tudo
            UIViewController *vc = [UIViewController new];
            vc.view.backgroundColor = UIColor.clearColor;
            
            PPPanelView *panelView = [[PPPanelView alloc] initWithFrame:activeScene.coordinateSpace.bounds];
            [vc.view addSubview:panelView];
            
            PPOverlayWindow.rootViewController = vc;
        }
        PPOverlayWindow.hidden = NO;
        // REMOVIDO o makeKeyAndVisible() que travava o jogo
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
