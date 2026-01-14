#!/bin/bash
source ./functions.sh

# Pandoc kontrolü
if ! command -v pandoc >/dev/null 2>&1; then
    whiptail --msgbox "Pandoc yüklü değil!\nKurmak için: sudo apt install pandoc" 10 60
    exit 1
fi

while true; do

    # --- DOSYA AL ---
    INPUT_FILE=$(whiptail --inputbox "Dönüştürülecek dosya yolu:" 10 60 \
        3>&1 1>&2 2>&3)

    [[ $? -ne 0 ]] && exit 0
    [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]] && continue

    filename=$(basename "$INPUT_FILE")
    ext="${filename##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # --- FORMAT ---
    if [[ "$ext" == "pdf" ]]; then
        FORMAT=$(whiptail --menu "PDF algılandı. Format seçin:" 15 60 5 \
            docx "" odt "" html "" md "" txt "" \
            3>&1 1>&2 2>&3)
    else
        FORMAT=$(whiptail --menu "Format seçin:" 15 60 8 \
            pdf "" docx "" odt "" html "" md "" txt "" epub "" pptx "" \
            3>&1 1>&2 2>&3)
    fi

    [[ $? -ne 0 ]] && continue

    # --- KLASÖR ---
    OUTPUT_DIR=$(whiptail --inputbox "Kaydedilecek klasör:" 10 60 \
        "$(dirname "$INPUT_FILE")" \
        3>&1 1>&2 2>&3)

    [[ -z "$OUTPUT_DIR" || ! -d "$OUTPUT_DIR" ]] && continue

    # --- DÖNÜŞTÜR ---
    RESULT=$(convert_file "$INPUT_FILE" "$FORMAT" "$OUTPUT_DIR")

    # --- SONRASI SEÇENEK ---
    whiptail --menu "İşlem sonucu:\n\n$RESULT\n\nNe yapmak istiyorsunuz?" 18 70 2 \
        "1" "Ana menüye dön" \
        "2" "Uygulamayı kapat" \
        3>&1 1>&2 2>&3

    [[ $? -eq 1 ]] && exit 0
done
