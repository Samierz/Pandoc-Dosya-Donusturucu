#!/bin/bash
source ./functions.sh

# Pandoc kontrolü
if ! command -v pandoc >/dev/null 2>&1; then
    yad --error --title="Hata" \
        --text="Pandoc yüklü değil!\n\nKurmak için:\nsudo apt install pandoc"
    exit 1
fi

start_gui() {
    while true; do

        # --- ADIM 1: DOSYA SEÇ ---
        FILE_DATA=$(yad --title="Adım 1/2: Dosya Seçimi" \
            --width=600 \
            --center \
            --image="emblem-documents" \
            --text="<big><b>Dosya Seçimi</b></big>\n\nDönüştürülecek dosyayı seçin." \
            --form \
            --field="Dosya Seçin:FL" \
            --button="İptal:1" \
            --button="İleri:0")

        [[ $? -ne 0 ]] && exit 0

        INPUT_FILE=$(echo "$FILE_DATA" | cut -d'|' -f1)
        [[ -z "$INPUT_FILE" ]] && continue

        filename=$(basename "$INPUT_FILE")
        ext="${filename##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

        if [[ "$ext" == "pdf" ]]; then
            FORMAT_LIST="docx!odt!html!md!txt"
            MSG_TEXT="<span color='blue'>PDF algılandı.</span>"
        else
            FORMAT_LIST="pdf!docx!odt!html!md!txt!epub!pptx"
            MSG_TEXT="Tüm formatlar aktif."
        fi

        DEFAULT_DIR=$(dirname "$INPUT_FILE")

        # --- ADIM 2: AYARLAR ---
        SETTINGS=$(yad --title="Adım 2/2: Ayarlar" \
            --width=600 \
            --center \
            --image="gtk-preferences" \
            --text="<b>$filename</b>\n$MSG_TEXT" \
            --form \
            --field="Hedef Format:CB" \
            --field="Kaydedilecek Klasör:DIR" \
            --button="Geri:2" \
            --button="Dönüştür:0" \
            "$FORMAT_LIST" "$DEFAULT_DIR")

        EXIT_CODE=$?
        [[ $EXIT_CODE -eq 2 ]] && continue
        [[ $EXIT_CODE -ne 0 ]] && exit 0

        FORMAT=$(echo "$SETTINGS" | cut -d'|' -f1)
        OUTPUT_DIR=$(echo "$SETTINGS" | cut -d'|' -f2)
        [[ -z "$FORMAT" || -z "$OUTPUT_DIR" ]] && continue

        # --- DÖNÜŞTÜR ---
        (
            echo "10"
            echo "# Dosya işleniyor..."
            convert_file "$INPUT_FILE" "$FORMAT" "$OUTPUT_DIR" > /tmp/convert_result.txt 2>&1
            echo "100"
        ) | yad --progress --title="İşleniyor" --pulsate --auto-close --center

        RESULT_TEXT=$(cat /tmp/convert_result.txt)

        # --- SONUÇ + SEÇENEK ---
        if echo "$RESULT_TEXT" | grep -q "BAŞARILI"; then
            yad --title="Başarılı" \
                --image="gtk-ok" \
                --center \
                --text="$RESULT_TEXT" \
                --button="Ana Menüye Dön:0" \
                --button="Uygulamayı Kapat:1"
            [[ $? -eq 1 ]] && exit 0
        else
            yad --title="Hata" \
                --image="gtk-dialog-error" \
                --center \
                --text="$RESULT_TEXT" \
                --button="Ana Menüye Dön:0" \
                --button="Uygulamayı Kapat:1"
            [[ $? -eq 1 ]] && exit 0
        fi
    done
}

start_gui
