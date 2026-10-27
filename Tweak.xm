#import <UIKit/UIKit.h>

static UIWindow *PPOverlayWindow;

@interface PPPanelViewController : UIViewController
@end

@implementation PPPanelViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];

    UIView *card = [UIView new];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = [UIColor colorWithRed:0.075 green:0.055 blue:0.11 alpha:1];
    card.layer.cornerRadius = 20;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [UIColor colorWithRed:0.62 green:0.25 blue:0.95 alpha:1].CGColor;
    [self.view addSubview:card];

    UILabel *title = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"PURPOU PANEL";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    title.textAlignment = NSTextAlignmentCenter;
    [card addSubview:title];

    UILabel *subtitle = [UILabel new];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    subtitle.text = @"Painel visual demonstrativo";
    subtitle.textColor = [UIColor colorWithWhite:0.82 alpha:1];
    subtitle.font = [UIFont systemFontOfSize:13];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [card addSubview:subtitle];

    UIButton *test = [UIButton buttonWithType:UIButtonTypeSystem];
    test.translatesAutoresizingMaskIntoConstraints = NO;
    test.backgroundColor = [UIColor colorWithRed:0.43 green:0.16 blue:0.72 alpha:1];
    test.layer.cornerRadius = 11;
    [test setTitle:@"Ação de teste" forState:UIControlStateNormal];
    [test setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [test addTarget:self action:@selector(testTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:test];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.translatesAutoresizingMaskIntoConstraints = NO;
    close.backgroundColor = [UIColor colorWithWhite:1 alpha:0.09];
    close.layer.cornerRadius = 11;
    [close setTitle:@"Fechar painel" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:close];

    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [card.widthAnchor constraintEqualToConstant:290],
        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [subtitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8],
        [subtitle.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
        [subtitle.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12],
        [test.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:22],
        [test.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [test.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [test.heightAnchor constraintEqualToConstant:44],
        [close.topAnchor constraintEqualToAnchor:test.bottomAnchor constant:10],
        [close.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [close.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [close.heightAnchor constraintEqualToConstant:44],
        [close.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18]
    ]];
}

- (void)testTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"PURPOU PANEL"
        message:@"O painel está funcionando." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeTapped {
    PPOverlayWindow.hidden = YES;
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
            PPOverlayWindow.windowLevel = UIWindowLevelAlert + 1;
            PPOverlayWindow.backgroundColor = UIColor.clearColor;
            PPOverlayWindow.rootViewController = [PPPanelViewController new];
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                    dispatch_get_main_queue(), ^{ PPShowPanel(); });
            }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{ PPShowPanel(); });
    }
}
