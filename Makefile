TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PurpouPanel

# Aqui diz pro Theos compilar o Tweak.xm, os arquivos C++ do ImGui e o backend do Metal
PurpouPanel_FILES = Tweak.xm imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_tables.cpp imgui/imgui_widgets.cpp imgui/backends/imgui_impl_metal.mm

# Frameworks nativos necessários pro Metal e ImGui
PurpouPanel_FRAMEWORKS = UIKit Foundation QuartzCore Metal MetalKit

# Diz onde o compilador deve procurar os headers (.h)
PurpouPanel_CFLAGS = -Iimgui -Iimgui/backends -I. -lstdc++

include $(THEOS_MAKE_PATH)/tweak.mk
