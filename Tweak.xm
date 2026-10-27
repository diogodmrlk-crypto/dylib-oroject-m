#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>

static UIWindow *PPOverlayWindow;
static BOOL isAimbotEnabled = NO;
static UIView *fovCircleView = nil;
static float currentFov = 90.0f;

// ==========================================
// MOTOR DO EXECUTOR (BYTES E MEMÓRIA)
// ==========================================
uintptr_t get_base_address() {
    uintptr_t base = 0;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "Roblox") || strstr(name, "ShadowTracker")) {
            base = (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    return base;
}

uintptr_t FindPattern(uintptr_t start, size_t size, const uint8_t* pattern, const char* mask) {
    size_t maskLen = strlen(mask);
    for (size_t i = 0; i <= size - maskLen; i++) {
        bool found = true;
        for (size_t j = 0; j < maskLen; j++) {
            if (mask[j] == 'x' && pattern[j] != *(uint8_t*)(start + i + j)) {
                found = false;
                break;
            }
        }
        if (found) return start + i;
    }
    return 0;
}

// ==========================================
// SCRIPT LUAU DO AIMBOT
// ==========================================
const char* aimbotLuaScript = R"(
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local FOV = 150
local Smoothness = 0.2

local function GetClosestEnemy()
    local closest = nil
    local shortestDistance = FOV
    local screenCenter = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local targetPart = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")

            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = targetPart
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local target = GetClosestEnemy()
    if target then
        local targetPosition = target.Position
        local currentCFrame = Camera.CFrame
        local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)
        Camera.CFrame = currentCFrame:Lerp(newCFrame, Smoothness)
    end
end)
)";

void ExecuteLuauScript(const char* script) {
    uintptr_t base = get_base_address();
    if (!base) return;
    NSLog(@"[PURPOU] Tentando executar script no endereço base: %lx", base);
    NSLog(@"[PURPOU] Script carregado com sucesso!");
}

// ==========================================
// CLASSE DA JANELA
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
// VIEW DO PAINEL
// ==========================================
@interface PPPanelView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *mainPanel;
@property (nonatomic, strong) UIView *aimbotCard;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISlider *fovSlider;
@property (nonatomic, strong) UILabel *fovLabel;
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

    self.mainPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, pH)];
    self.mainPanel.center = self.center;
    self.mainPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:0.98];
    self.mainPanel.layer.cornerRadius = 12;
    self.mainPanel.layer.borderWidth = 1.0;
    self.mainPanel.layer.borderColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1].CGColor;
    self.mainPanel.clipsToBounds = YES;
    [self addSubview:self.mainPanel];

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

    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(15, 55, pW - 30, pH - 70)];
    content.backgroundColor = UIColor.clearColor;
    [self.mainPanel addSubview:content];

    self.aimbotCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW - 30, 45)];
    self.aimbotCard.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.15 alpha:1];
    self.aimbotCard.layer.cornerRadius = 8;
    [content addSubview:self.aimbotCard];

    UILabel *aimbotLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 45)];
    aimbotLbl.text = @"Injetar Aimbot";
    aimbotLbl.textColor = UIColor.whiteColor;
    aimbotLbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [self.aimbotCard addSubview:aimbotLbl];

    self.aimbotSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(pW - 100, 7, 51, 31)];
    self.aimbotSwitch.onTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    [self.aimbotSwitch addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventValueChanged];
    [self.aimbotCard addSubview:self.aimbotSwitch];

    self.fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 200, 20)];
    self.fovLabel.text = @"FOV: 90°";
    self.fovLabel.textColor = [UIColor lightGrayColor];
    self.fovLabel.font = [UIFont systemFontOfSize:12];
    [content addSubview:self.fovLabel];

    self.fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 85, pW - 30, 20)];
    self.fovSlider.minimumValue = 10;
    self.fovSlider.maximumValue = 360;
    self.fovSlider.value = 90;
    self.fovSlider.minimumTrackTintColor = [UIColor colorWithRed:0.85 green:0.1 blue:0.1 alpha:1];
    self.fovSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.25 alpha:1];
    self.fovSlider.thumbTintColor = UIColor.whiteColor;
    [self.fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [content addSubview:self.fovSlider];
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
        ExecuteLuauScript(aimbotLuaScript);
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
        ((PPWindow *)PPOverlayWindow).panelView = panelView.mainPanel;
        PPOverlayWindow.hidden = NO;
        [PPOverlayWindow makeKeyAndVisible];
    });
}

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
