#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// Variáveis globais
static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;

// Declaração da função do Roblox (o offset precisa ser atualizado no futuro)
// Aqui você puxaria a função real do Roblox via hook, mas pra testar, vamos usar a lógica base.

@interface PPPanelViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *card;
@end

@implementation PPPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    // O Painel Quadrado
    self.card = [UIView new];
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    self.card.backgroundColor = [UIColor colorWithRed:0.075 green:0.055 blue:0.11 alpha:0.95];
    self.card.layer.cornerRadius = 12;
    self.card.layer.borderWidth = 1.5;
    self.card.layer.borderColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1].CGColor;
    [self.view addSubview:self.card];

    // Adiciona o gesto de arrastar no painel
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.card addGestureRecognizer:pan];

    // Título
    UILabel *title = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"PURPOU EXECUTOR";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    title.textAlignment = NSTextAlignmentCenter;
    [self.card addSubview:title];

    // Botão Aimbot
    UIButton *aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimbotBtn.translatesAutoresizingMaskIntoConstraints = NO;
    aimbotBtn.backgroundColor = [UIColor colorWithRed:0.43 green:0.16 blue:0.72 alpha:1];
    aimbotBtn.layer.cornerRadius = 8;
    [aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    [aimbotBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    aimbotBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [aimbotBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:aimbotBtn];

    // Botão de Fechar (X)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:closeBtn];

    [NSLayoutConstraint activateConstraints:@[
        [self.card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.card.widthAnchor constraintEqualToConstant:180],
        [self.card.heightAnchor constraintEqualToConstant:120],

        [title.topAnchor constraintEqualToAnchor:self.card.topAnchor constant:10],
        [title.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:10],
        [title.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-10],

        [closeBtn.topAnchor constraintEqualToAnchor:self.card.topAnchor constant:8],
        [closeBtn.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-8],
        [closeBtn.widthAnchor constraintEqualToConstant:20],
        [closeBtn.heightAnchor constraintEqualToConstant:20],

        [aimbotBtn.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:15],
        [aimbotBtn.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor constant:15],
        [aimbotBtn.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor constant:-15],
        [aimbotBtn.heightAnchor constraintEqualToConstant:36]
    ]];
}

// Lógica do Arrastar
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

// Lógica da Toggle Aimbot
- (void)toggleAimbot:(UIButton *)sender {
    isAimbotEnabled = !isAimbotEnabled;
    if (isAimbotEnabled) {
        [sender setTitle:@"Aimbot: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.4 alpha:1]; // Vermelho/Rosa
    } else {
        [sender setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.43 green:0.16 blue:0.72 alpha:1]; // Roxo
    }
}

- (void)closeTapped {
    PPOverlayWindow.hidden = YES;
}
@end

// Função que mostra o painel na tela do Roblox
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
            PPOverlayWindow.windowLevel = UIWindowLevelAlert + 1;
            PPOverlayWindow.backgroundColor = UIColor.clearColor;
            PPOverlayWindow.rootViewController = [PPPanelViewController new];
        }
        PPOverlayWindow.hidden = NO;
        [PPOverlayWindow makeKeyAndVisible];
    });
}

// Hook que roda quando a dylib é injetada
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

// =====================================================================
// AQUI ENTRA O MOTOR DO AIMBOT (Lógica de memória do Roblox)
// =====================================================================
// O Roblox usa o motor Unity. Pra fazer o Aimbot funcionar de verdade, 
// você precisa hookar a função de renderização do jogo.
// Como o Roblox atualiza os offsets toda semana, o código abaixo é um 
// exemplo do que você colocaria no loop de renderização.

/*
extern "C" void* (*old_CameraUpdate)(void* camera);
extern "C" void* new_CameraUpdate(void* camera) {
    if (isAimbotEnabled) {
        // 1. Ler a lista de jogadores (Players)
        // 2. Calcular a distância do centro da tela até a cabeça de cada jogador
        // 3. Achar o mais próximo
        // 4. Rotacionar a câmera pra apontar pra ele
    }
    return old_CameraUpdate(camera);
}
%hookf(void*, CameraUpdate, void* camera) {
    return new_CameraUpdate(camera);
}
*/
