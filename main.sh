#!/bin/bash
export GDK_BACKEND=x11


# Kullanıcıya sor: GUI mi TUI mi?
CHOICE=$(yad --title="Arayüz Seçimi" \
    --text="Hangi arayüz ile devam etmek istersiniz?" \
    --button="GUI (Grafik Arayüz):0" \
    --button="TUI (Terminal Arayüz):1")

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    ./gui_mode.sh
elif [ $EXIT_CODE -eq 1 ]; then
    ./tui_mode.sh
else
    exit 0
fi
