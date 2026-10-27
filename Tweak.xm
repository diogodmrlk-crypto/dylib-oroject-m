#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "imgui/imgui.h"
#import "imgui/backends/imgui_impl_metal.h"
#import "layout.h" // Aqui ele puxa o teu código gigante

static UIWindow *PPOverlayWindow;

// A view que desenha o ImGui usando Metal
@interface PPImGuiView : MTKView
@end

@implementation PPImGuiView {
    id<MTLCommandQueue> _commandQueue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        self.device = device;
        self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        self.clearColor = MTLClearColorMake(0, 0, 0, 0); // Fundo transparente pro jogo aparecer atrás
        self.opaque = NO;
        
        _commandQueue = [device newCommandQueue];
        
        // Inicializa o ImGui
        ImGui::CreateContext();
        ImGui_ImplMetal_Init(device);
        
        // Loop que roda a 60 FPS pra desenhar o menu
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)render {
    MTLRenderPassDescriptor *desc = self.currentRenderPassDescriptor;
    if (!desc) return;

    id<MTLCommandBuffer> cmd = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:desc];
    
    ImGui_ImplMetal_NewFrame(desc);
    ImGui::NewFrame();
    
    // AQUI ELE CHAMA A TUA FUNÇÃO DO LAYOUT.H
    menu(); 
    
    ImGui::Render();
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), cmd, enc);
    
    [enc endEncoding];
    [cmd presentDrawable:self.currentDrawable];
    [cmd commit];
}
@end

// Função que cria a janela e põe a view do ImGui lá dentro
static void PPShowPanel(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (PPOverlayWindow) return;

        UIWindowScene *activeScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (!activeScene) return;

        PPOverlayWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
        PPOverlayWindow.frame = activeScene.coordinateSpace.bounds;
        PPOverlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
        PPOverlayWindow.backgroundColor = UIColor.clearColor;
        
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.clearColor;
        
        PPImGuiView *imguiView = [[PPImGuiView alloc] initWithFrame:PPOverlayWindow.bounds];
        [vc.view addSubview:imguiView];
        
        PPOverlayWindow.rootViewController = vc;
        PPOverlayWindow.hidden = NO;
        [PPOverlayWindow makeKeyAndVisible];
    });
}

%ctor {
    @autoreleasepool {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{ PPShowPanel(); });
    }
}
