#include <imports.h>
#include <imguiconfig.h>
#include "particles.h"
#include <string>
#include <chrono>
#include <map>

#ifndef OBFUSCATE
#define OBFUSCATE(str) str
#endif

int targetIndex = 0; // 0=Cabeça, 1=Pescoço, 2=Peito
int radioOption = 2; // 1=Ao Olhar (PADRÃO ATIVADO), 2=Ao Atirar

enum class BoxStyle;
enum class LinePosition;

extern ImVec4 ThemeFov;

static bool botao_vp = false;
static bool botao_tp = false;
static bool botao_selint = false;
static bool botao_ligado = false;
static bool botaospeedhack = false;
static bool botaoselint = false;
static bool botaoTp = false;
static bool botaovp = false;

// ---------------- Variáveis ESP ----------------
int nickStyles = 0; // 0=Com Fundo, 1=Sem Fundo

// Variáveis novas para as funções
bool FastParachute = false;
bool RevealEnemies = false; 
bool FreeMovement = false;

// Variáveis globais
bool init = true;
static ParticleSystem particleSystem(150, 0.05f);

// Variáveis principais
bool showMenu = false;
static int tapCount = 0;
static double lastTapTime = 0;
static float anim = 0.0f;
static bool isOpening = true;
static ImFont* sansFont = nullptr;

// Cores
ImVec4 espColor = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
ImVec4 fovColor = ImVec4(1.0f, 1.0f, 0.0f, 1.0f);
static ImVec4 panelColor = ImVec4(0.85f, 0.05f, 0.05f, 1.0f);
static ImVec4 lineColor  = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);

// Color Picker
static bool openColorPicker = false;

// CONSTANTES PARA BORDA IGUAL PARA TODOS (DECLARADAS GLOBALMENTE)
const float BORDER_ROUNDING = 26.0f; // MESMO ARREDONDAMENTO
const float BORDER_SIZE = 1.5f; // MESMA ESPESSURA

/*// Variáveis para Aimbot
static float Fov = 50.0f; // Valor inicial do FOV
static int aimPosition = 0; // Posição do aim (0=Cabeça, 1=Pescoço, etc.)
static bool Active = false;
static bool AimbotRage = false;
static bool AimbotLegit = false;
static bool EspCircle = false;
static bool AimbotAuto = false;
static bool HidePanel = false;

// Variáveis para ESP
static bool EspLine = false;
static bool EspBox = false;
static bool EspVida = false;
static bool Nick = false;
static bool Inimigos = false;
static bool EspSkeleton = false;
static bool EspInfo = false;*/

// Variáveis para cores
static ImVec4 ThemeColer = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

// Variável para tema escuro
static bool temaEscuro = false;

void ApplyCustomTheme(const ImVec4& mainColor, bool darkTheme = false) {
    ImGuiStyle& style = ImGui::GetStyle();
    ImVec4* colors = style.Colors;

    ImVec4 light(fmin(mainColor.x + 0.05f, 1.0f),    
                 fmin(mainColor.y + 0.05f, 1.0f),    
                 fmin(mainColor.z + 0.05f, 1.0f), 1.0f);    

    ImVec4 dark(mainColor.x * 0.85f, mainColor.y * 0.85f, mainColor.z * 0.85f, 1.0f);    

    if (darkTheme) {
        // TEMA ESCURO - NETUNO (azul escuro/cinza)
        ImVec4 netunoBg = ImVec4(0.10f, 0.12f, 0.16f, 1.00f); // Fundo principal netuno
        ImVec4 netunoCard = ImVec4(0.15f, 0.18f, 0.22f, 1.00f); // Cards/netuno médio
        ImVec4 netunoLight = ImVec4(0.20f, 0.23f, 0.28f, 1.00f); // Elementos claros
        ImVec4 netunoText = ImVec4(0.80f, 0.83f, 0.87f, 1.00f); // Texto claro
        ImVec4 netunoBorder = ImVec4(0.25f, 0.28f, 0.35f, 1.00f); // Bordas
        
        // Cores do tema Netuno escuro
        colors[ImGuiCol_WindowBg]         = netunoBg;    
        colors[ImGuiCol_ChildBg]          = netunoBg;    
        colors[ImGuiCol_TitleBg]          = netunoCard;    
        colors[ImGuiCol_TitleBgActive]    = netunoCard;    
        colors[ImGuiCol_TitleBgCollapsed] = netunoCard;    
        colors[ImGuiCol_Button]           = netunoCard;    
        colors[ImGuiCol_ButtonHovered]    = netunoLight;    
        colors[ImGuiCol_ButtonActive]     = netunoLight;    
        colors[ImGuiCol_Header]           = netunoCard;    
        colors[ImGuiCol_HeaderHovered]    = netunoLight;    
        colors[ImGuiCol_HeaderActive]     = netunoLight;    

        colors[ImGuiCol_CheckMark]        = mainColor;  
        colors[ImGuiCol_FrameBg]          = netunoCard;    
        colors[ImGuiCol_FrameBgHovered]   = netunoLight;    
        colors[ImGuiCol_FrameBgActive]    = mainColor;    

        // Borda Netuno
        colors[ImGuiCol_Border]           = netunoBorder;
        colors[ImGuiCol_BorderShadow]     = ImVec4(0, 0, 0, 0);    

        colors[ImGuiCol_ScrollbarBg]      = ImVec4(0.08f, 0.10f, 0.14f, 0.30f);
        colors[ImGuiCol_ScrollbarGrab]    = ImVec4(0.30f, 0.33f, 0.40f, 0.80f);
        colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.35f, 0.38f, 0.45f, 0.80f);
        colors[ImGuiCol_ScrollbarGrabActive]  = ImVec4(0.40f, 0.43f, 0.50f, 0.80f);

        colors[ImGuiCol_PopupBg]          = netunoCard;

        // Texto claro no tema escuro
        colors[ImGuiCol_Text]             = netunoText;
        colors[ImGuiCol_TextDisabled]     = ImVec4(0.50f, 0.53f, 0.58f, 1.00f);
    } else {
        // TEMA CLARO (original)
        colors[ImGuiCol_WindowBg]         = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_ChildBg]          = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_TitleBg]          = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_TitleBgActive]    = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_TitleBgCollapsed] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_Button]           = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_ButtonHovered]    = ImVec4(0.95f, 0.95f, 0.95f, 1.00f);
        colors[ImGuiCol_ButtonActive]     = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);
        colors[ImGuiCol_Header]           = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_HeaderHovered]    = ImVec4(0.95f, 0.95f, 0.95f, 1.00f);
        colors[ImGuiCol_HeaderActive]     = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);

        colors[ImGuiCol_CheckMark]        = mainColor;  
        colors[ImGuiCol_FrameBg]          = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
        colors[ImGuiCol_FrameBgHovered]   = ImVec4(0.95f, 0.95f, 0.95f, 1.00f);
        colors[ImGuiCol_FrameBgActive]    = mainColor;    

        colors[ImGuiCol_Border]           = ImVec4(0.80f, 0.80f, 0.80f, 0.50f);
        colors[ImGuiCol_BorderShadow]     = ImVec4(0, 0, 0, 0);    

        colors[ImGuiCol_ScrollbarBg]      = ImVec4(0.96f, 0.96f, 0.96f, 0.30f);
        colors[ImGuiCol_ScrollbarGrab]    = ImVec4(0.70f, 0.70f, 0.70f, 0.80f);
        colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.60f, 0.60f, 0.60f, 0.80f);
        colors[ImGuiCol_ScrollbarGrabActive]  = ImVec4(0.50f, 0.50f, 0.50f, 0.80f);

        colors[ImGuiCol_PopupBg]          = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);

        colors[ImGuiCol_Text]             = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
        colors[ImGuiCol_TextDisabled]     = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
    }

    style.WindowBorderSize = 0.0f;    
    style.FrameBorderSize  = 0.0f;
    style.TabBorderSize    = 0.0f;    
    style.FrameRounding    = 20.0f;
    style.WindowRounding   = 20.0f;    
    style.GrabRounding     = 20.0f;
    style.TabRounding      = 20.0f;
    style.ScrollbarRounding = 12.0f;
    style.WindowPadding    = ImVec2(12, 10);    
    style.FramePadding     = ImVec2(10, 10);
    style.ItemSpacing      = ImVec2(10, 8);
    style.ItemInnerSpacing = ImVec2(8, 6);    
    style.IndentSpacing    = 25.0f;    
    style.WindowTitleAlign = ImVec2(0.1f, 0.5f);    
    style.ScrollbarSize    = 20.0f;
    style.GrabMinSize      = 25.0f;
}

void DrawHorizontalLine(float extraTopSpace = 6.0f, float extraBottomSpace = 10.0f) {
    ImGui::Dummy(ImVec2(0, extraTopSpace));
    ImVec2 p = ImGui::GetCursorScreenPos();
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    draw_list->AddLine(
        ImVec2(p.x, p.y),
        ImVec2(p.x + ImGui::GetContentRegionAvail().x, p.y),
        ImColor(lineColor), 1.0f
    );
    ImGui::Dummy(ImVec2(0, extraBottomSpace));
}

// FUNÇÃO PARA CABEÇALHO DE TAB COM BOTÃO CLOSE FIXO NO CANTO DIREITO
void CabecalhoTabComClose(ImTextureID iconTexture, const char* titulo, bool* fechar = nullptr) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    
    // DIMENSÕES AJUSTADAS
    const float altura = 46.0f; // Altura do cabeçalho
    const float iconSize = 28.0f;
    const float closeButtonSize = 38.0f;
    const float themeButtonSize = 38.0f; // Mesmo tamanho do close
    
    // Calcular tamanho do texto
    ImVec2 textSize = ImGui::CalcTextSize(titulo);
    
    // Calcular largura do cabeçalho - ATÉ O MEIO DO PAINEL
    float largura_painel = ImGui::GetContentRegionAvail().x;
    float cabecalho_largura = largura_painel * 0.5f; // ATÉ O MEIO DO PAINEL
    
    // POSIÇÃO À ESQUERDA (como estava)
    const ImVec2 pos = ImVec2(window->DC.CursorPos.x, window->DC.CursorPos.y + 8.0f);
    
    const ImRect cabecalho_bb(pos, ImVec2(pos.x + cabecalho_largura, pos.y + altura));
    
    // BOTÕES NO CANTO DIREITO - MODIFICADO: botões mais para a esquerda
    float close_x = ImGui::GetWindowPos().x + ImGui::GetWindowSize().x - 60.0f; // 60px da direita (era 90)
    float theme_x = close_x - themeButtonSize - 15.0f; // 15px de espaçamento entre os botões (era 10)
    float buttons_y = pos.y + (altura - closeButtonSize) * 0.5f; // Centralizado verticalmente
    
    // BOTÃO DE TEMA (lua/sol)
    ImRect theme_bb(
        ImVec2(theme_x, buttons_y),
        ImVec2(theme_x + themeButtonSize, buttons_y + themeButtonSize)
    );
    
    // BOTÃO CLOSE
    ImRect close_bb(
        ImVec2(close_x, buttons_y),
        ImVec2(close_x + closeButtonSize, buttons_y + closeButtonSize)
    );
    
    // Fundo do cabeçalho - COR DEPENDE DO TEMA
    ImU32 cor_fundo;
    if (temaEscuro) {
        cor_fundo = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno no tema escuro
    } else {
        cor_fundo = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco no tema claro
    }
    
    // Desenhar fundo do cabeçalho (até o meio do painel)
    window->DrawList->AddRectFilled(cabecalho_bb.Min, cabecalho_bb.Max, cor_fundo, BORDER_ROUNDING);
    
    // BORDA - COR DEPENDE DO TEMA
    ImU32 cor_borda;
    if (temaEscuro) {
        cor_borda = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
    } else {
        cor_borda = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
    }
    window->DrawList->AddRect(cabecalho_bb.Min, cabecalho_bb.Max, cor_borda, BORDER_ROUNDING, 0, BORDER_SIZE);
    
    // ÍCONE À ESQUERDA (na posição normal) - COR DO PAINEL
    ImVec2 iconPos = ImVec2(
        pos.x + 15.0f,
        pos.y + (altura - iconSize) * 0.5f
    );
    window->DrawList->AddImage(
        iconTexture,
        iconPos,
        ImVec2(iconPos.x + iconSize, iconPos.y + iconSize),
        ImVec2(0, 0), ImVec2(1, 1),
        ImGui::GetColorU32(panelColor)
    );
    
    // TEXTO AO LADO DO ÍCONE - COR DO PAINEL
    ImVec2 texto_pos = ImVec2(
        iconPos.x + iconSize + 10.0f,
        pos.y + (altura - textSize.y) * 0.5f
    );
    ImU32 cor_texto = ImGui::GetColorU32(panelColor);
    window->DrawList->AddText(texto_pos, cor_texto, titulo);
    
    // ----- BOTÃO DE TEMA -----
    bool theme_hovered = ImGui::IsMouseHoveringRect(theme_bb.Min, theme_bb.Max);
    
    // Cor do botão de tema - DEPENDE DO TEMA
    ImU32 theme_color;
    if (theme_hovered) {
        if (temaEscuro) {
            theme_color = ImGui::GetColorU32(ImVec4(0.20f, 0.23f, 0.28f, 1.0f)); // Netuno claro no hover
        } else {
            theme_color = ImGui::GetColorU32(ImVec4(0.95f, 0.95f, 0.95f, 1.0f)); // Cinza muito claro no hover
        }
    } else {
        if (temaEscuro) {
            theme_color = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.0f)); // Card Netuno
        } else {
            theme_color = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.0f)); // Branco normal
        }
    }
    
    // Desenhar botão de tema (círculo)
    ImVec2 theme_center = ImVec2(
        theme_bb.Min.x + themeButtonSize * 0.5f,
        theme_bb.Min.y + themeButtonSize * 0.5f
    );
    float theme_radius = themeButtonSize * 0.5f;
    
    // Fundo do botão (círculo) - TRANSPARENTE como solicitado
    // Não desenhamos fundo, apenas a lua vermelha
    
    // Borda do botão de tema - COR DEPENDE DO TEMA (linha fina estilo iOS)
    ImU32 theme_border_color;
    if (temaEscuro) {
        theme_border_color = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
    } else {
        theme_border_color = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
    }
    
    // Borda fina estilo iOS (1.0f em vez de BORDER_SIZE)
    window->DrawList->AddCircle(theme_center, theme_radius, theme_border_color, 0, 1.0f);
    
    // Desenhar símbolo de lua vermelha estilo iOS (sem fundo)
    float moon_size = themeButtonSize * 0.35f; // Tamanho da lua
    
    // Lua vermelha (cor do painel) - estilo iOS (linha fina)
    ImU32 moon_color = ImGui::GetColorU32(panelColor); // Vermelho
    
    // Desenhar círculo externo da lua (linha fina estilo iOS)
    window->DrawList->AddCircle(theme_center, moon_size, moon_color, 0, 1.5f);
    
    // Desenhar "orelha" da lua (fase crescente) - estilo iOS
    // A "orelha" é apenas um círculo menor com a cor do fundo do botão para criar a ilusão de fase
    float ear_size = moon_size * 0.8f;
    ImVec2 ear_center = ImVec2(
        theme_center.x + moon_size * 0.25f, // Pequeno deslocamento para fase crescente
        theme_center.y
    );
    
    // Usar a cor do tema para "cortar" a lua (criar fase crescente)
    window->DrawList->AddCircleFilled(ear_center, ear_size, theme_color);
    
    // Se quiser borda na orelha para combinar com estilo iOS (opcional)
    // window->DrawList->AddCircle(ear_center, ear_size, theme_border_color, 0, 1.0f);
    
    // Verificar clique no botão de tema
    if (theme_hovered && ImGui::IsMouseClicked(0)) {
        temaEscuro = !temaEscuro;
        
        // Mudar cores do tema quando alternar
        if (temaEscuro) {
            // Tema Netuno (azul escuro/cinza)
            panelColor = ImVec4(0.85f, 0.05f, 0.05f, 1.0f); // Vermelho mesmo no tema escuro
            lineColor = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
        } else {
            // Tema claro original
            panelColor = ImVec4(0.85f, 0.05f, 0.05f, 1.0f); // Vermelho original
            lineColor = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
        }
    }
    
    // ----- BOTÃO CLOSE -----
    bool close_hovered = ImGui::IsMouseHoveringRect(close_bb.Min, close_bb.Max);
    
    // Botão close - COR DEPENDE DO TEMA
    ImU32 close_color;
    if (close_hovered) {
        if (temaEscuro) {
            close_color = ImGui::GetColorU32(ImVec4(0.20f, 0.23f, 0.28f, 1.0f)); // Netuno claro no hover
        } else {
            close_color = ImGui::GetColorU32(ImVec4(0.95f, 0.95f, 0.95f, 1.0f)); // Cinza muito claro no hover
        }
    } else {
        if (temaEscuro) {
            close_color = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.0f)); // Card Netuno
        } else {
            close_color = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.0f)); // Branco normal
        }
    }
    
    // Desenhar botão close 100% arredondado
    ImVec2 close_center = ImVec2(
        close_bb.Min.x + closeButtonSize * 0.5f,
        close_bb.Min.y + closeButtonSize * 0.5f
    );
    float close_radius = closeButtonSize * 0.5f;
    
    window->DrawList->AddCircleFilled(close_center, close_radius, close_color);
    
    // Borda do botão close - COR DEPENDE DO TEMA (linha fina estilo iOS)
    ImU32 close_border_color;
    if (temaEscuro) {
        close_border_color = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
    } else {
        close_border_color = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
    }
    window->DrawList->AddCircle(close_center, close_radius, close_border_color, 0, 1.0f); // Linha fina
    
    // Desenhar o "X" dentro do botão - COR DESTACADA
    float cross_size = closeButtonSize * 0.4f;
    ImVec2 cross_start = ImVec2(
        close_center.x - cross_size * 0.5f,
        close_center.y - cross_size * 0.5f
    );
    ImVec2 cross_end = ImVec2(
        close_center.x + cross_size * 0.5f,
        close_center.y + cross_size * 0.5f
    );
    
    ImU32 cross_color;
    if (temaEscuro) {
        cross_color = ImGui::GetColorU32(ImVec4(0.90f, 0.30f, 0.30f, 1.0f)); // Vermelho Netuno
    } else {
        cross_color = ImGui::GetColorU32(ImVec4(0.90f, 0.20f, 0.20f, 1.0f)); // Vermelho claro
    }
    window->DrawList->AddLine(cross_start, cross_end, cross_color, 2.0f);
    window->DrawList->AddLine(
        ImVec2(cross_start.x, cross_end.y),
        ImVec2(cross_end.x, cross_start.y),
        cross_color, 2.0f
    );
    
    // Apenas para ocupar espaço vertical
    ImGui::ItemSize(cabecalho_bb, 0);
    
    // Verificar clique no botão close
    if (close_hovered && ImGui::IsMouseClicked(0) && fechar != nullptr) {
        *fechar = false; // Fecha o menu
    }
}

// BOTÃO NO ESTILO DA SEGUNDA IMAGEM - APENAS A BOLINHA MUDA DE COR
bool NovoBotaoEstilo(const char* label, bool* v, const char* tag = nullptr) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;
    
    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    
    // DIMENSÕES AUMENTADAS
    const float altura = 52.0f;
    const float largura = ImGui::GetContentRegionAvail().x - 5.0f;
    const float toggle_diametro = 32.0f;
    
    const ImVec2 pos = window->DC.CursorPos;
    const ImRect total_bb(pos, ImVec2(pos.x + largura, pos.y + altura));
    
    ImGui::ItemSize(total_bb, style.FramePadding.y);
    if (!ImGui::ItemAdd(total_bb, id))
        return false;
    
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(total_bb, id, &hovered, &held);
    if (pressed) {
        *v = !(*v);
        ImGui::MarkItemEdited(id);
    }
    
    // Cores - DEPENDE DO TEMA
    ImU32 cor_fundo;
    ImU32 cor_texto;
    
    if (hovered) {
        if (temaEscuro) {
            cor_fundo = ImGui::GetColorU32(ImVec4(0.20f, 0.23f, 0.28f, 1.00f)); // Netuno claro no hover
        } else {
            cor_fundo = ImGui::GetColorU32(ImVec4(0.95f, 0.95f, 0.95f, 1.00f)); // Cinza muito claro no hover
        }
    } else {
        if (temaEscuro) {
            cor_fundo = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
        } else {
            cor_fundo = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco normal
        }
    }
    
    if (temaEscuro) {
        cor_texto = ImGui::GetColorU32(ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
    } else {
        cor_texto = ImGui::GetColorU32(ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Texto preto
    }
    
    ImU32 cor_botao_redondo;
    if (*v) {
        cor_botao_redondo = ImGui::GetColorU32(panelColor);
    } else {
        if (temaEscuro) {
            cor_botao_redondo = ImGui::GetColorU32(ImVec4(0.30f, 0.33f, 0.40f, 1.0f)); // Cinza Netuno quando desligado
        } else {
            cor_botao_redondo = ImGui::GetColorU32(ImVec4(0.80f, 0.80f, 0.80f, 1.0f)); // Cinza claro quando desligado
        }
    }
    
    // FUNDO COM BORDAS MUITO ARREDONDADAS
    window->DrawList->AddRectFilled(total_bb.Min, total_bb.Max, cor_fundo, BORDER_ROUNDING);
    
    // BORDA - COR DEPENDE DO TEMA
    ImU32 cor_borda;
    if (temaEscuro) {
        cor_borda = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
    } else {
        cor_borda = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
    }
    window->DrawList->AddRect(total_bb.Min, total_bb.Max, cor_borda, BORDER_ROUNDING, 0, BORDER_SIZE);
    
    // TEXTO À ESQUERDA
    ImVec2 texto_pos = ImVec2(pos.x + 18.0f, pos.y + (altura - ImGui::GetFontSize()) * 0.5f);
    window->DrawList->AddText(texto_pos, cor_texto, label);
    
    // TAG "NOVO" (se tiver)
    if (tag) {
        ImVec2 tag_tamanho = ImGui::CalcTextSize(tag);
        ImVec2 tag_pos = ImVec2(texto_pos.x + ImGui::CalcTextSize(label).x + 12.0f, 
                               pos.y + (altura - tag_tamanho.y) * 0.5f);
        
        ImU32 tag_fundo = ImGui::GetColorU32(ImVec4(0.90f, 0.20f, 0.20f, 1.0f));
        ImVec2 tag_padding = ImVec2(10.0f, 5.0f);
        ImRect tag_bb = ImRect(
            ImVec2(tag_pos.x - tag_padding.x, tag_pos.y - tag_padding.y),
            ImVec2(tag_pos.x + tag_tamanho.x + tag_padding.x, tag_pos.y + tag_tamanho.y + tag_padding.y)
        );
        
        float tag_rounding = 14.0f;
        window->DrawList->AddRectFilled(tag_bb.Min, tag_bb.Max, tag_fundo, tag_rounding);
        window->DrawList->AddRect(tag_bb.Min, tag_bb.Max, 
                                 ImGui::GetColorU32(ImVec4(1.0f, 0.3f, 0.3f, 1.0f)), tag_rounding, 0, 2.0f);
        
        window->DrawList->AddText(tag_pos, ImGui::GetColorU32(ImVec4(1.0f, 1.0f, 1.0f, 1.0f)), tag);
    }
    
    // BOTÃO REDONDO À DIREITA - APENAS ELE MUDA DE COR
    float botao_x = total_bb.Max.x - toggle_diametro - 18.0f;
    float botao_y = pos.y + (altura - toggle_diametro) * 0.5f;
    
    ImVec2 centro_botao = ImVec2(botao_x + toggle_diametro * 0.5f, botao_y + toggle_diametro * 0.5f);
    float raio = toggle_diametro * 0.5f;
    
    // Fundo do botão redondo - COR MUDA CONFORME ESTADO
    window->DrawList->AddCircleFilled(centro_botao, raio, cor_botao_redondo);
    
    // Borda sutil no botão redondo
    ImU32 cor_borda_botao;
    if (*v) {
        cor_borda_botao = ImGui::GetColorU32(ImVec4(
            panelColor.x * 0.8f, 
            panelColor.y * 0.8f, 
            panelColor.z * 0.8f, 
            1.0f
        ));
    } else {
        if (temaEscuro) {
            cor_borda_botao = ImGui::GetColorU32(ImVec4(0.20f, 0.23f, 0.28f, 1.0f)); // Borda Netuno
        } else {
            cor_borda_botao = ImGui::GetColorU32(ImVec4(0.70f, 0.70f, 0.70f, 1.0f)); // Cinza claro
        }
    }
    window->DrawList->AddCircle(centro_botao, raio, cor_borda_botao, 0, BORDER_SIZE);
    
    return pressed;
}

// FUNÇÃO PARA TÍTULO DE SEÇÃO
void TituloSecao(const char* titulo) {
    ImGui::Dummy(ImVec2(0, 12));
    if (temaEscuro) {
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 0.9f)); // Texto claro Netuno
    } else {
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 0.9f)); // Preto
    }
    ImGui::Text("%s", titulo);
    ImGui::PopStyleColor();
    ImGui::Dummy(ImVec2(0, 6));
}

// CHECKBOX NO ESTILO DA SEGUNDA IMAGEM
bool CustomCheckbox12(const char* label, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const ImVec2 label_size = ImGui::CalcTextSize(label, NULL, true);

    const float square_sz = ImGui::GetFrameHeight() * 1.2f;
    const ImVec2 pos = window->DC.CursorPos;
    const ImRect total_bb(pos, ImVec2(pos.x + square_sz + (label_size.x > 0.0f ? style.ItemInnerSpacing.x + label_size.x : 0.0f), pos.y + label_size.y + style.FramePadding.y * 2.0f));
    
    ImGui::ItemSize(total_bb, style.FramePadding.y);
    if (!ImGui::ItemAdd(total_bb, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(total_bb, id, &hovered, &held);
    
    if (hovered && g.IO.MouseClicked[0]) {
        *v = !(*v);
        ImGui::MarkItemEdited(id);
        pressed = true;
    }

    const ImRect check_bb(pos, ImVec2(pos.x + square_sz, pos.y + square_sz));

    static std::map<ImGuiID, float> animTimes;
    float& animTime = animTimes[id];

    if (pressed) {
        animTime = 1.0f;
    } else if (animTime > 0.0f) {
        animTime -= g.IO.DeltaTime * 8.0f;
        if (animTime < 0.0f) animTime = 0.0f;
    }

    float scale = 1.0f - (animTime * 0.2f);

    ImVec2 center = ImVec2((check_bb.Min.x + check_bb.Max.x) * 0.5f, (check_bb.Min.y + check_bb.Max.y) * 0.5f);
    ImVec2 size = ImVec2((check_bb.Max.x - check_bb.Min.x) * scale, (check_bb.Max.y - check_bb.Min.y) * scale);
    ImRect anim_bb = ImRect(center.x - size.x * 0.5f, center.y - size.y * 0.5f, center.x + size.x * 0.5f, center.y + size.y * 0.5f);

    // COR DE FUNDO - DEPENDE DO TEMA E ESTADO
    ImU32 bg_color;
    if (*v) {
        bg_color = ImGui::GetColorU32(panelColor);
    } else {
        if (temaEscuro) {
            bg_color = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.0f)); // Card Netuno
        } else {
            bg_color = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.0f)); // Branco
        }
    }

    // Fundo com bordas MUITO arredondadas - MESMO ARREDONDAMENTO
    window->DrawList->AddRectFilled(anim_bb.Min, anim_bb.Max, bg_color, BORDER_ROUNDING);

    // BORDA - MESMA PARA TODOS, MAS COR DEPENDE DO TEMA
    if (*v) {
        ImU32 border_color = ImGui::GetColorU32(ImVec4(
            panelColor.x * 1.1f, 
            panelColor.y * 1.1f, 
            panelColor.z * 1.1f, 
            1.0f
        ));
        window->DrawList->AddRect(anim_bb.Min, anim_bb.Max, border_color, BORDER_ROUNDING, 0, BORDER_SIZE);
    } else {
        ImU32 border_color;
        if (temaEscuro) {
            border_color = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
        } else {
            border_color = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
        }
        window->DrawList->AddRect(anim_bb.Min, anim_bb.Max, border_color, BORDER_ROUNDING, 0, BORDER_SIZE);
    }

    // Texto - COR DEPENDE DO TEMA
    if (label_size.x > 0.0f) {
        if (temaEscuro) {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
        } else {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
        }
        ImGui::RenderText(ImVec2(check_bb.Max.x + style.ItemInnerSpacing.x + 5.0f, pos.y + style.FramePadding.y), label);
        ImGui::PopStyleColor();
    }

    return pressed;
}

// SLIDER FOV NO ESTILO DA SEGUNDA IMAGEM
bool CustomSliderFloatFOV(const char* label, float* v, float v_min, float v_max, const char* format = "%.1f") {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;
    
    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const float w = ImGui::CalcItemWidth();
    
    const ImVec2 label_size = ImGui::CalcTextSize(label, NULL, true);
    const ImRect frame_bb(window->DC.CursorPos, ImVec2(window->DC.CursorPos.x + w, window->DC.CursorPos.y + 36.0f));
    const ImRect total_bb(frame_bb.Min, ImVec2(frame_bb.Max.x + (label_size.x > 0.0f ? style.ItemInnerSpacing.x + label_size.x : 0.0f), frame_bb.Max.y));
    
    ImGui::ItemSize(total_bb, style.FramePadding.y);
    if (!ImGui::ItemAdd(total_bb, id, &frame_bb))
        return false;
    
    const bool hovered = ImGui::ItemHoverable(frame_bb, id);
    
    // FUNDO DO SLIDER - DEPENDE DO TEMA
    ImU32 frame_col;
    if (temaEscuro) {
        frame_col = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
    } else {
        frame_col = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco
    }
    window->DrawList->AddRectFilled(frame_bb.Min, frame_bb.Max, frame_col, BORDER_ROUNDING);
    
    // BORDA DO SLIDER - DEPENDE DO TEMA
    ImU32 border_col;
    if (temaEscuro) {
        border_col = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
    } else {
        border_col = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
    }
    window->DrawList->AddRect(frame_bb.Min, frame_bb.Max, border_col, BORDER_ROUNDING, 0, BORDER_SIZE);
    
    // PREENCHIMENTO COM COR DO PAINEL
    float t = (*v - v_min) / (v_max - v_min);
    ImRect fill_bb = frame_bb;
    fill_bb.Max.x = ImLerp(fill_bb.Min.x, fill_bb.Max.x, t);
    
    if (t > 0.0f) {
        ImU32 fill_col = ImGui::GetColorU32(panelColor);
        window->DrawList->AddRectFilled(fill_bb.Min, fill_bb.Max, fill_col, BORDER_ROUNDING);
    }
    
    // VALOR NO CENTRO - TEXTO DEPENDE DO TEMA
    char value_buf[64];
    const char* value_buf_end = value_buf + ImFormatString(value_buf, IM_ARRAYSIZE(value_buf), format, *v);
    
    ImU32 text_col;
    if (temaEscuro) {
        text_col = ImGui::GetColorU32(ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
    } else {
        text_col = ImGui::GetColorU32(ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
    }
    
    ImVec2 text_size = ImGui::CalcTextSize(value_buf);
    ImVec2 text_pos = ImVec2(
        frame_bb.Min.x + (frame_bb.Max.x - frame_bb.Min.x) * 0.5f - text_size.x * 0.5f,
        frame_bb.Min.y + (frame_bb.Max.y - frame_bb.Min.y) * 0.5f - text_size.y * 0.5f
    );
    
    window->DrawList->AddText(text_pos, text_col, value_buf);
    
    // LABEL (se houver)
    if (label_size.x > 0.0f) {
        // Mude temporariamente a cor do texto
        if (temaEscuro) {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
        } else {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
        }
        
        ImGui::RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x + 5.0f, 
                                frame_bb.Min.y + (frame_bb.Max.y - frame_bb.Min.y) * 0.5f - label_size.y * 0.5f), 
                         label);
        
        ImGui::PopStyleColor();
    }
    
    // INTERAÇÃO
    if (hovered && g.IO.MouseClicked[0]) {
        ImGui::SetActiveID(id, window);
        ImGui::SetFocusID(id, window);
        ImGui::FocusWindow(window);
    }
    
    if (g.ActiveId == id) {
        if (g.IO.MouseDown[0]) {
            const float mouse_pos_x = g.IO.MousePos.x;
            const float normalized_pos = ImClamp((mouse_pos_x - frame_bb.Min.x) / (frame_bb.Max.x - frame_bb.Min.x), 0.0f, 1.0f);
            *v = v_min + normalized_pos * (v_max - v_min);
            return true;
        } else {
            ImGui::ClearActiveID();
        }
    }
    
    return false;
}

// SLIDER PADRÃO (para outras configurações)
bool CustomSliderFloat(const char* label, float* v, float v_min, float v_max, const char* format = "%.1f") {
    return CustomSliderFloatFOV(label, v, v_min, v_max, format);
}

void menu() {
    ImVec2 imageSize(28, 28);
    ApplyCustomTheme(panelColor, temaEscuro);
    static int activeTab = 1;

    anim = ImClamp(anim + (ImGui::GetIO().DeltaTime / 0.2f) * (isOpening ? 1.0f : -1.0f), 0.0f, 1.0f);    
    
    // JANELA MAIOR PARA ACOMODAR BOTÕES MAIS ALTOS E SCROLLBAR
    ImVec2 winSize = ImVec2(630 * anim, 520 * anim);

    if (anim > 0.0f) {    
        ImGui::SetNextWindowSize(winSize, ImGuiCond_Always);    
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, anim);    
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 20.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    }    

    if (init) {    
        ImGui::PushFont(sansFont);    
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(15.0f, 12.0f));
        
        // Janela sem título e flutuante
        if (ImGui::Begin("##MenuFloating", &init, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoTitleBar)) {    
            ImGui::BeginChild("LeftBar", ImVec2(100, 0), false);

            // BOTÕES DAS TABS 100% ARREDONDADOS
            ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 999.0f);
            ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0.0f);
            
            // Cores para os ícones das tabs - DEPENDE DO TEMA
            ImU32 iconColorInactive;
            ImU32 iconColorActive = ImGui::GetColorU32(panelColor); // Vermelho (cor do painel)
            ImU32 borderColor;
            
            if (temaEscuro) {
                iconColorInactive = ImGui::GetColorU32(ImVec4(0.50f, 0.53f, 0.60f, 1.0f)); // Cinza Netuno
                borderColor = ImGui::GetColorU32(ImVec4(0.30f, 0.33f, 0.40f, 1.0f)); // Borda Netuno
            } else {
                iconColorInactive = ImGui::GetColorU32(ImVec4(0.81f, 0.81f, 0.81f, 1.0f)); // #CFCFCF
                borderColor = ImGui::GetColorU32(ImVec4(0.81f, 0.81f, 0.81f, 1.0f)); // #CFCFCF para borda
            }
            
            // Tab 1 - Aimbot
            if (ImGui::Button("##tab1", ImVec2(75, 75))) activeTab = 1;    
            {  
                bool isActive = (activeTab == 1);
                
                ImVec2 p = ImGui::GetItemRectMin();   
                ImVec2 s = ImGui::GetItemRectSize();    
                ImVec2 imgPos(p.x + (s.x - imageSize.x) * 0.5f, p.y + (s.y - imageSize.y) * 0.5f);    
                
                // Escolher a cor do ícone baseado na tab ativa
                ImU32 iconColor = isActive ? iconColorActive : iconColorInactive;
                
                // Desenhar o ícone com a cor apropriada
                ImGui::GetWindowDrawList()->AddImage(iconaim.textureId, imgPos,    
                    ImVec2(imgPos.x + imageSize.x, imgPos.y + imageSize.y), 
                    ImVec2(0,0), ImVec2(1,1), iconColor);
                    
                // DESENHAR BORDA PARA TODAS AS TABS
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                ImVec2 p_min = ImGui::GetItemRectMin();
                ImVec2 p_max = ImGui::GetItemRectMax();
                ImVec2 center = ImVec2((p_min.x + p_max.x) * 0.5f, (p_min.y + p_max.y) * 0.5f);
                float radius = (p_max.x - p_min.x) * 0.5f;
                
                // Borda fina para TODAS as tabs
                draw_list->AddCircle(center, radius - 2.0f, borderColor, 0, 0.8f);
            }    

            // Tab 2 - ESP
            if (ImGui::Button("##tab2", ImVec2(75, 75))) activeTab = 2;    
            {  
                bool isActive = (activeTab == 2);
                
                ImVec2 p = ImGui::GetItemRectMin();   
                ImVec2 s = ImGui::GetItemRectSize();    
                ImVec2 imgPos(p.x + (s.x - imageSize.x) * 0.5f,    
                p.y + (s.y - imageSize.y) * 0.5f);    
                
                // Escolher a cor do ícone baseado na tab ativa
                ImU32 iconColor = isActive ? iconColorActive : iconColorInactive;
                
                ImGui::GetWindowDrawList()->AddImage(iconesp.textureId, imgPos,    
                    ImVec2(imgPos.x + imageSize.x, imgPos.y + imageSize.y), 
                    ImVec2(0,0), ImVec2(1,1), iconColor);
                    
                // DESENHAR BORDA PARA TODAS AS TABS
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                ImVec2 p_min = ImGui::GetItemRectMin();
                ImVec2 p_max = ImGui::GetItemRectMax();
                ImVec2 center = ImVec2((p_min.x + p_max.x) * 0.5f, (p_min.y + p_max.y) * 0.5f);
                float radius = (p_max.x - p_min.x) * 0.5f;
                
                // Borda fina para TODAS as tabs
                draw_list->AddCircle(center, radius - 2.0f, borderColor, 0, 0.8f);
            }    

            // Tab 3 - Diversos
            if (ImGui::Button("##tab3", ImVec2(75, 75))) activeTab = 3;    
            {  
                bool isActive = (activeTab == 3);
                
                ImVec2 p = ImGui::GetItemRectMin();   
                ImVec2 s = ImGui::GetItemRectSize();    
                ImVec2 imgPos(p.x + (s.x - imageSize.x) * 0.5f,    
                p.y + (s.y - imageSize.y) * 0.5f);    
                
                // Escolher a cor do ícone baseado na tab ativa
                ImU32 iconColor = isActive ? iconColorActive : iconColorInactive;
                
                ImGui::GetWindowDrawList()->AddImage(iconmisc.textureId, imgPos,    
                    ImVec2(imgPos.x + imageSize.x, imgPos.y + imageSize.y), 
                    ImVec2(0,0), ImVec2(1,1), iconColor);
                    
                // DESENHAR BORDA PARA TODAS AS TABS
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                ImVec2 p_min = ImGui::GetItemRectMin();
                ImVec2 p_max = ImGui::GetItemRectMax();
                ImVec2 center = ImVec2((p_min.x + p_max.x) * 0.5f, (p_min.y + p_max.y) * 0.5f);
                float radius = (p_max.x - p_min.x) * 0.5f;
                
                // Borda fina para TODAS as tabs
                draw_list->AddCircle(center, radius - 2.0f, borderColor, 0, 0.8f);
            }    

            // Tab 4 - Info
            if (ImGui::Button("##tab4", ImVec2(75, 75))) activeTab = 4;    
            {  
                bool isActive = (activeTab == 4);
                
                ImVec2 p = ImGui::GetItemRectMin();   
                ImVec2 s = ImGui::GetItemRectSize();    
                ImVec2 imgPos(p.x + (s.x - imageSize.x) * 0.5f,    
                p.y + (s.y - imageSize.y) * 0.5f);    
                
                // Escolher a cor do ícone baseado na tab ativa
                ImU32 iconColor = isActive ? iconColorActive : iconColorInactive;
                
                ImGui::GetWindowDrawList()->AddImage(iconinfo.textureId, imgPos,    
                    ImVec2(imgPos.x + imageSize.x, imgPos.y + imageSize.y), 
                    ImVec2(0,0), ImVec2(1,1), iconColor);
                    
                // DESENHAR BORDA PARA TODAS AS TABS
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                ImVec2 p_min = ImGui::GetItemRectMin();
                ImVec2 p_max = ImGui::GetItemRectMax();
                ImVec2 center = ImVec2((p_min.x + p_max.x) * 0.5f, (p_min.y + p_max.y) * 0.5f);
                float radius = (p_max.x - p_min.x) * 0.5f;
                
                // Borda fina para TODAS as tabs
                draw_list->AddCircle(center, radius - 2.0f, borderColor, 0, 0.8f);
            }    

            ImGui::PopStyleVar(2);
            ImGui::EndChild();    
            ImGui::SameLine(0, 10);    

            ImGui::BeginChild("ContentArea", ImVec2(0, 0), false);    

            // CABEÇALHO COM BOTÃO CLOSE (AJUSTADO - ATÉ A METADE E CENTRALIZADO)
            if (activeTab == 1) {
                CabecalhoTabComClose(iconaim.textureId, "AIMBOT", &init);
            } else if (activeTab == 2) {
                CabecalhoTabComClose(iconesp.textureId, "ESP", &init);
            } else if (activeTab == 3) {
                CabecalhoTabComClose(iconmisc.textureId, "DIVERSOS", &init);
            } else if (activeTab == 4) {
                CabecalhoTabComClose(iconinfo.textureId, "INFORMAÇÕES", &init);
            }
            
            ImGui::Dummy(ImVec2(0, 18)); // Espaçamento após o cabeçalho

            // ------------------------------ TAB 1 (AIMBOT) COM SCROLLBAR ------------------------------
            if (activeTab == 1) {
                // Adicionar scrollbar para a aba Aimbot - REMOVIDA BORDA QUADRADA
                ImGui::BeginChild("AimbotScroll", ImVec2(0, ImGui::GetContentRegionAvail().y - 10), false, ImGuiWindowFlags_AlwaysVerticalScrollbar);
                
                // Botões no novo estilo
                NovoBotaoEstilo("Habilitar Aimblt", &Active);
                NovoBotaoEstilo("Aimbot Legit", &AimbotRage);
                NovoBotaoEstilo("Exibir Fov", &AimbotLegit);
                NovoBotaoEstilo("Exibir Linha", &EspCircle);
                
                ImGui::Dummy(ImVec2(0, 15)); // REDUZIDO de 20 para 15
                
                // TÍTULO FOV E VALOR FORA DO CARD (VALOR À DIREITA)
                ImGuiWindow* window = ImGui::GetCurrentWindow();
                ImVec2 text_pos = window->DC.CursorPos;
                
                // Calcular largura disponível
                float available_width = ImGui::GetContentRegionAvail().x;
                
                // Texto "FOV:" à esquerda - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                
                ImGui::Text("FOV:");
                ImGui::PopStyleColor();
                
                // Valor do FOV em vermelho com colchetes à direita
                // Formatar valor do FOV com colchetes
                char fov_text[32];
                snprintf(fov_text, sizeof(fov_text), "[%.0f°]", Fov);
                
                // Calcular o tamanho do texto do valor
                ImVec2 fov_value_size = ImGui::CalcTextSize(fov_text);
                
                // Calcular posição à direita (alinhada com a borda do conteúdo)
                float right_padding = 5.0f; // Pequeno padding da direita
                float fov_value_x = text_pos.x + available_width - fov_value_size.x - right_padding;
                
                // Garantir que não sobreponha o texto "FOV:"
                float fov_text_width = ImGui::CalcTextSize("FOV:").x + 10.0f; // Texto "FOV:" + margem
                if (fov_value_x < text_pos.x + fov_text_width) {
                    fov_value_x = text_pos.x + fov_text_width;
                }
                
                ImVec2 fov_value_pos = ImVec2(fov_value_x, text_pos.y);
                
                // Desenhar valor do FOV em vermelho
                window->DrawList->AddText(fov_value_pos, ImGui::GetColorU32(panelColor), fov_text);
                
                // Avançar o cursor após o texto - REDUZIDO para ficar mais perto do card
                ImGui::Dummy(ImVec2(0, 8)); // REDUZIDO de fov_value_size.y + 10 para 8
                
                // Card do FOV (apenas o slider) - MOVIDO PARA CIMA
                ImVec2 card_pos = window->DC.CursorPos;
                float card_width = ImGui::GetContentRegionAvail().x - 5.0f;
                float card_height = 60.0f; // Altura reduzida apenas para o slider
                
                // BORDA MUITO MAIS ARREDONDADA E MAIS FINA
                const float FOV_ROUNDING = 38.0f;
                const float FOV_BORDER_SIZE = 0.8f;
                
                // Fundo do card com borda arredondada - DEPENDE DO TEMA
                ImU32 card_bg;
                ImU32 card_border;
                
                if (temaEscuro) {
                    card_bg = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
                    card_border = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
                } else {
                    card_bg = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco
                    card_border = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
                }
                
                // Desenhar card
                window->DrawList->AddRectFilled(card_pos, ImVec2(card_pos.x + card_width, card_pos.y + card_height), card_bg, FOV_ROUNDING);
                window->DrawList->AddRect(card_pos, ImVec2(card_pos.x + card_width, card_pos.y + card_height), card_border, FOV_ROUNDING, 0, FOV_BORDER_SIZE);
                
                // Slider do FOV - MAIS SIMPLES (linha central)
                float slider_y = card_pos.y + card_height/2;
                float slider_width = card_width - 40.0f;
                ImRect slider_bb = ImRect(
                    ImVec2(card_pos.x + 20.0f, slider_y - 4.0f),
                    ImVec2(card_pos.x + 20.0f + slider_width, slider_y + 4.0f)
                );
                
                // Fundo do slider (linha fina) - DEPENDE DO TEMA
                ImU32 slider_bg;
                if (temaEscuro) {
                    slider_bg = ImGui::GetColorU32(ImVec4(0.10f, 0.12f, 0.16f, 1.00f)); // Netuno mais escuro
                } else {
                    slider_bg = ImGui::GetColorU32(ImVec4(0.90f, 0.90f, 0.90f, 1.00f)); // Cinza muito claro
                }
                window->DrawList->AddRectFilled(
                    ImVec2(slider_bb.Min.x, slider_y - 2.0f),
                    ImVec2(slider_bb.Max.x, slider_y + 2.0f),
                    slider_bg, 2.0f
                );
                
                // Área preenchida do slider
                float t = (Fov - 0.0f) / (760.0f - 0.0f);
                float filled_width = slider_width * t;
                
                if (filled_width > 0) {
                    ImRect filled_bb = ImRect(
                        ImVec2(slider_bb.Min.x, slider_y - 2.0f),
                        ImVec2(slider_bb.Min.x + filled_width, slider_y + 2.0f)
                    );
                    
                    ImU32 filled_color = ImGui::GetColorU32(panelColor);
                    window->DrawList->AddRectFilled(filled_bb.Min, filled_bb.Max, filled_color, 2.0f);
                }
                
                // Marcador do slider (bolinha no meio da linha)
                float marker_x = slider_bb.Min.x + slider_width * t;
                ImVec2 marker_center = ImVec2(marker_x, slider_y);
                
                ImU32 marker_color = ImGui::GetColorU32(panelColor);
                window->DrawList->AddCircleFilled(marker_center, 8.0f, marker_color);
                
                // Borda do marcador - DEPENDE DO TEMA
                ImU32 marker_border_color;
                if (temaEscuro) {
                    marker_border_color = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
                } else {
                    marker_border_color = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
                }
                window->DrawList->AddCircle(marker_center, 8.0f, marker_border_color, 0, 0.6f);
                
                // Interação do slider
                static bool slider_active = false;
                static ImGuiID slider_id = 0;
                bool slider_hovered = ImGui::IsMouseHoveringRect(
                    ImVec2(slider_bb.Min.x, slider_bb.Min.y - 15.0f),
                    ImVec2(slider_bb.Max.x, slider_bb.Max.y + 15.0f)
                );
                
                if (slider_hovered && ImGui::IsMouseClicked(0)) {
                    slider_active = true;
                    slider_id = ImGui::GetID("##FovSlider");
                    ImGui::SetActiveID(slider_id, window);
                    ImGui::SetFocusID(slider_id, window);
                    ImGui::FocusWindow(window);
                }
                
                if (slider_active && ImGui::IsMouseDown(0)) {
                    float mouse_x = ImGui::GetMousePos().x;
                    float normalized = (mouse_x - slider_bb.Min.x) / slider_width;
                    normalized = ImClamp(normalized, 0.0f, 1.0f);
                    Fov = normalized * 760.0f;
                } else if (slider_active && !ImGui::IsMouseDown(0)) {
                    slider_active = false;
                    if (ImGui::GetActiveID() == slider_id) {
                        ImGui::ClearActiveID();
                    }
                }
                
                // Avançar o cursor após o card - REDUZIDO
                ImGui::Dummy(ImVec2(0, card_height + 8)); // REDUZIDO de +10 para +8

                ImGui::Spacing();
                ImGui::Spacing();

                // COMBOBOX "Puxada" - estilo simplificado
                const char* items[] = { "Cabeça", "Pescoço", "Peito", "Quadril" };
                const char* current_item = items[aimPosition];
                
                // Texto "Puxada:" - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                ImGui::Text("Puxada:");
                ImGui::PopStyleColor();
                
                ImGui::SameLine();
                ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5.0f);
                
                // Estilo do combobox - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
                    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.20f, 0.23f, 0.28f, 1.00f)); // Netuno claro
                    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
                    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.20f, 0.23f, 0.28f, 1.00f)); // Netuno claro
                    ImGui::PushStyleColor(ImGuiCol_ButtonActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco
                    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.95f, 0.95f, 0.95f, 1.00f)); // Cinza muito claro
                    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco
                    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.95f, 0.95f, 0.95f, 1.00f)); // Cinza muito claro
                    ImGui::PushStyleColor(ImGuiCol_ButtonActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                
                ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, BORDER_ROUNDING);
                ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(10.0f, 8.0f));
                
                if (ImGui::BeginCombo("##PuxadaCombo", current_item, ImGuiComboFlags_NoArrowButton)) {
                    for (int n = 0; n < IM_ARRAYSIZE(items); n++) {
                        bool is_selected = (aimPosition == n);
                        if (ImGui::Selectable(items[n], is_selected)) {
                            aimPosition = n;
                        }
                        if (is_selected) {
                            ImGui::SetItemDefaultFocus();
                        }
                    }
                    ImGui::EndCombo();
                }
                
                ImGui::PopStyleVar(2);
                ImGui::PopStyleColor(7);

                ImGui::Spacing();
                ImGui::Spacing();

                // RADIO BUTTONS para tipo de aimbot
                // Texto "Tipo de Aimbot:" - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                ImGui::Text("Tipo de Aimbot:");
                ImGui::PopStyleColor();
                
                ImGui::Spacing();
                
                // Cores dos radio buttons - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.15f, 0.18f, 0.22f, 1.00f)); // Card Netuno
                    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_CheckMark, panelColor);
                } else {
                    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(1.00f, 1.00f, 1.00f, 1.00f)); // Branco
                    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, panelColor);
                    ImGui::PushStyleColor(ImGuiCol_CheckMark, panelColor);
                }
                
                // Texto dos radio buttons - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                
                if (ImGui::RadioButton("Ao Olhar", AimbotAuto)) {
                    AimbotAuto = true;
                    HidePanel = false;
                }
                
                ImGui::SameLine();
                
                if (ImGui::RadioButton("Ao Atirar", !AimbotAuto)) {
                    AimbotAuto = false;
                    HidePanel = true;
                }
                
                ImGui::PopStyleColor(temaEscuro ? 5 : 5); // Pop das cores dos radio buttons + texto
                
                ImGui::EndChild(); // Fim do scrollbar da aba Aimbot
            }

            // ------------------------------ TAB 2 (ESP) SEM SCROLLBAR ------------------------------  
            if (activeTab == 2) {
                // SEM SCROLLBAR
                ImGui::BeginChild("ESPScroll", ImVec2(0, 0), false);
                
                // Botões ESP no novo estilo - TODOS COM MESMA BORDA
                NovoBotaoEstilo("ESP Linha", &EspLine);
                NovoBotaoEstilo("ESP Caixa", &EspBox);
                NovoBotaoEstilo("ESP Vida", &EspVida);
                NovoBotaoEstilo("ESP Nome", &Nick);
                NovoBotaoEstilo("ESP Inimigos", &Inimigos);
                NovoBotaoEstilo("ESP Skeleton", &EspSkeleton);
                NovoBotaoEstilo("ESP Info", &EspInfo);
                
                ImGui::EndChild(); // Fim da aba ESP
            } 

            // ------------------------------ TAB 3 (DIVERSOS) SEM SCROLLBAR ------------------------------  
            if (activeTab == 3) {
                // SEM SCROLLBAR
                ImGui::BeginChild("MiscScroll", ImVec2(0, 0), false);
                
                NovoBotaoEstilo("Aim Silent", &botaoselint);
                NovoBotaoEstilo("Voar Player", &botaovp);
                NovoBotaoEstilo("Speed Hack ", &botaospeedhack);
                NovoBotaoEstilo("Tp Player", &botaoTp);
                
                ImGui::PushItemWidth(250);
                
                // Color pickers
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                }
                if (ImGui::ColorEdit3("##CorPainelLinhas", (float*)&panelColor, ImGuiColorEditFlags_NoInputs)) {    
                    lineColor = panelColor;    
                }  
                ImGui::SameLine();
                ImGui::ColorEdit3("Cor ESP", (float*)&ThemeColer, ImGuiColorEditFlags_NoInputs);
                if (temaEscuro) {
                    ImGui::PopStyleColor();
                }
                
                // Botão Salvar Config - COM MESMA BORDA
                ImGui::Dummy(ImVec2(0, 10));
                ImVec2 savePos = ImGui::GetCursorScreenPos();
                ImVec2 saveSize = ImVec2(155, 48);
                ImRect saveRect(savePos, ImVec2(savePos.x + saveSize.x, savePos.y + saveSize.y));
                
                bool saveHovered = ImGui::IsMouseHoveringRect(saveRect.Min, saveRect.Max);
                ImU32 saveColor;
                if (saveHovered) {
                    if (temaEscuro) {
                        saveColor = ImGui::GetColorU32(ImVec4(0.20f, 0.23f, 0.28f, 1.0f)); // Netuno claro no hover
                    } else {
                        saveColor = ImGui::GetColorU32(ImVec4(0.95f, 0.95f, 0.95f, 1.0f)); // Cinza muito claro no hover
                    }
                } else {
                    if (temaEscuro) {
                        saveColor = ImGui::GetColorU32(ImVec4(0.15f, 0.18f, 0.22f, 1.0f)); // Card Netuno
                    } else {
                        saveColor = ImGui::GetColorU32(ImVec4(1.00f, 1.00f, 1.00f, 1.0f)); // Branco normal
                    }
                }
                
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                draw_list->AddRectFilled(saveRect.Min, saveRect.Max, saveColor, BORDER_ROUNDING);
                
                // Borda - DEPENDE DO TEMA
                ImU32 border_color;
                if (temaEscuro) {
                    border_color = ImGui::GetColorU32(ImVec4(0.25f, 0.28f, 0.35f, 1.0f)); // Borda Netuno
                } else {
                    border_color = ImGui::GetColorU32(ImVec4(0.85f, 0.85f, 0.85f, 1.0f)); // Cinza claro
                }
                draw_list->AddRect(saveRect.Min, saveRect.Max, border_color, BORDER_ROUNDING, 0, BORDER_SIZE);
                
                ImVec2 textSize = ImGui::CalcTextSize("Salvar Config");
                ImVec2 textPos = ImVec2(
                    savePos.x + (saveSize.x - textSize.x) * 0.5f,
                    savePos.y + (saveSize.y - textSize.y) * 0.5f
                );
                
                // Texto - DEPENDE DO TEMA
                ImU32 textColor;
                if (temaEscuro) {
                    textColor = ImGui::GetColorU32(ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    textColor = ImGui::GetColorU32(ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                draw_list->AddText(textPos, textColor, "Salvar Config");
                
                if (ImGui::InvisibleButton("##SalvarConfig", saveSize)) {
                    // Ação do botão
                }
                
                ImGui::EndChild(); // Fim da aba Diversos
            }    

            // ------------------------------ TAB 4 (INFO) SEM SCROLLBAR ------------------------------  
            if (activeTab == 4) {
                // SEM SCROLLBAR
                ImGui::BeginChild("InfoScroll", ImVec2(0, 0), false);
                
                // Texto das informações - DEPENDE DO TEMA
                if (temaEscuro) {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.80f, 0.83f, 0.87f, 1.0f)); // Texto claro Netuno
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.10f, 0.10f, 0.10f, 1.0f)); // Preto
                }
                
                ImGui::Text("Desenvolvido Por:"); ImGui::SameLine();
                ImGui::TextColored(panelColor, "@souza.wq");
                ImGui::Text("Versão do Jogo:"); ImGui::SameLine();
                ImGui::TextColored(panelColor, "Free Fire MAX");
                ImGui::Text("Key de Acesso:"); ImGui::SameLine();
                ImGui::TextColored(panelColor, "Souzaxiters-hour-00");
                
                ImGui::PopStyleColor();
                
                ImGui::EndChild(); // Fim da aba Info
            }    

            ImGui::EndChild();    
        }    

        ImGui::End();    
        ImGui::PopStyleVar(); // Remove o estilo do padding da janela
        if (sansFont) ImGui::PopFont();    
    }    

    if (anim > 0.0f) ImGui::PopStyleVar(3);
}

void RenderWithTripleTap() {
    ImGuiIO& io = ImGui::GetIO();
    double currentTime = ImGui::GetTime();

    int fingersDown = 0;    
    for (int i = 0; i < IM_ARRAYSIZE(io.MouseDown); i++) {    
        if (io.MouseDown[i])    
            fingersDown++;    
    }    

    if (fingersDown >= 3) {    
        tapCount++;    
        if (tapCount == 1)    
            lastTapTime = currentTime;    

        if (tapCount == 3 && (currentTime - lastTapTime) < 0.8) {    
            showMenu = !showMenu;    
            isOpening = showMenu;    
            tapCount = 0;    
        }   
        else if ((currentTime - lastTapTime) > 0.8) {    
            tapCount = 1;    
            lastTapTime = currentTime;    
        }    
    }   
    else if ((currentTime - lastTapTime) > 0.8 && tapCount > 0) {    
        tapCount = 0;    
    }    

    if (showMenu)    
        menu();
}
