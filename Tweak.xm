#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static UIWindow *PPOverlayWindow;
static UIView *PPGlobalPanelView = nil;

// ==========================================
// CLASSE DA JANELA (Toques corrigidos)
// ==========================================
@interface PPWindow : UIWindow
@property (nonatomic, weak) UIView *panelView;
@end

@implementation PPWindow

// Só bloqueia o toque se ele NÃO estiver dentro do painel
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.panelView && CGRectContainsPoint(self.panelView.frame, point)) {
        return [super hitTest:point withEvent:event]; // Toque no painel
    }
    return nil; // Toque no jogo
}
@end

// ==========================================
// VIEW DO PAINEL
// ==========================================
@interface PPPanelView : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *aimbotBtn;
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
    // Tamanho maior pra ficar igual ao print (340x180)
    CGFloat pW = 340.0;
    CGFloat pH = 180.0;

    // 1. PAINEL PRINCIPAL
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, pH)];
    self.panel.center = self.center;
    self.panel.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:0.98];
    self.panel.layer.cornerRadius = 4;
    self.panel.layer.borderWidth = 2.0;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1].CGColor;
    self.panel.clipsToBounds = YES;
    [self addSubview:self.panel];

    // Gesto de arrastar
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.header addGestureRecognizer:pan]; // Adicionado depois que header for criado

    // 2. CABEÇALHO VERMELHO
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, 35)];
    self.header.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
    [self.panel addSubview:self.header];

    // Título
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pW, 35)];
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:14];
    title.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:title];

    // Botão X
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(pW - 35, 0, 35, 35);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.header addSubview:closeBtn];

    // Adiciona o pan no header que agora existe
    UIPanGestureRecognizer *dragPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.header addGestureRecognizer:dragPan];

    // 3. CONTAINER DO CONTEÚDO
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(15, 50, pW - 30, 100)];
    content.backgroundColor = [UIColor clearColor];
    [self.panel addSubview:content];

    // Ícone Quadrado Vermelho
    UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 40, 40)];
    iconBox.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
    iconBox.layer.cornerRadius = 6;
    [content addSubview:iconBox];
    
    UILabel *iconTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    iconTxt.text = @"🎯";
    iconTxt.font = [UIFont systemFontOfSize:20];
    iconTxt.textAlignment = NSTextAlignmentCenter;
    [iconBox addSubview:iconTxt];

    // Texto Aimbot
    UILabel *aimbotLbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 120, 40)];
    aimbotLbl.text = @"Aimbot";
    aimbotLbl.textColor = UIColor.whiteColor;
    aimbotLbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [content addSubview:aimbotLbl];

    // BOTÃO TOGGLE
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aimbotBtn.frame = CGRectMake(pW - 90, 22, 60, 30);
    self.aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.aimbotBtn.layer.cornerRadius = 15;
    self.aimbotBtn.layer.borderWidth = 1;
    self.aimbotBtn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
    [self.aimbotBtn addTarget:self action:@selector(toggleAimbot) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:self.aimbotBtn];

    // Bolinha do Toggle
    UIView *thumb = [[UIView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
    thumb.backgroundColor = UIColor.whiteColor;
    thumb.layer.cornerRadius = 12;
    thumb.tag = 101;
    [self.aimbotBtn addSubview:thumb];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    self.panel.center = CGPointMake(self.panel.center.x + translation.x, self.panel.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)toggleAimbot {
    self.isAimbotEnabled = !self.isAimbotEnabled;
    UIView *thumb = [self.aimbotBtn viewWithTag:101];
    
    BOOL isEnabled = self.isAimbotEnabled;
    UIButton *btn = self.aimbotBtn;
    
    [UIView animateWithDuration:0.2 animations:^{
        if (isEnabled) {
            btn.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
            btn.layer.borderColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1].CGColor;
            thumb.frame = CGRectMake(33, 3, 24, 24);
        } else {
            btn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
            btn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1].CGColor;
            thumb.frame = CGRectMake(3, 3, 24, 24);
        }
    }];
}

- (void)closePanel {
    self.hidden = YES;
}
@end

// ==========================================
// LÓGICA DOS 3 DEDOS
// ==========================================
@interface PPTouchTrigger : NSObject
@end
@implementation PPTouchTrigger
+ (void)setup {
    // Escuta o toque na janela principal
    UIWindow *mainWin = UIApplication.sharedApplication.windows.firstObject;
    if (!mainWin) return;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggered)];
    tap.numberOfTouchesRequired = 3;
    tap.numberOfTapsRequired = 1;
    [mainWin addGestureRecognizer:tap];
}

+ (void)triggered {
    if (!PPOverlayWindow) {
        PPShowPanel();
    }
    PPOverlayWindow.hidden = !PPOverlayWindow.hidden;
    if (!PPOverlayWindow.hidden) {
        [PPOverlayWindow makeKeyAndVisible];
    }
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
        
        PPPanelView *panelView = [[PPPanelView alloc] initWithFrame:activeScene.coordinateSpace.bounds];
        [vc.view addSubview:panelView];
        
        PPOverlayWindow.rootViewController = vc;
        ((PPWindow *)PPOverlayWindow).panelView = panelView.panel;
        PPGlobalPanelView = panelView;

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
                        [PPTouchTrigger setup];
                    });
            }];
    }
}
