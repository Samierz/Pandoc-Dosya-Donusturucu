#!/bin/bash

convert_file() {
    local input_file="$1"
    local target_format="$2"
    local output_dir="$3"
    
    # 1. Dosya kontrolü
    if [ -z "$input_file" ]; then
        echo "HATA: Herhangi bir dosya seçmediniz."
        return 1
    fi

    # --- İSİM AYRIŞTIRMA ---
    full_filename=$(basename -- "$input_file")
    extension=$(echo "$full_filename" | awk -F. '{print $NF}')
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]') # Küçük harfe çevir
    
    filename=$(basename "$input_file" ".$extension")
    
    # --- KONTROLLER ---
    if [ "$extension" == "$target_format" ]; then
        echo "HATA: Giriş ve çıkış formatı aynı ($extension)."
        return 1
    fi 

    # --- HEDEF KLASÖR ---
    if [ -z "$output_dir" ]; then
        output_dir=$(dirname "$input_file")
    fi
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi

    output_file="${output_dir}/${filename}.${target_format}"

    # --- DÖNÜŞTÜRME MANTIĞI ---

    # SENARYO 1: Girdi PDF ise
    if [ "$extension" == "pdf" ]; then
        
        # A) PDF -> TXT
        if [ "$target_format" == "txt" ]; then
            echo "Bilgi: PDF metne çevriliyor..."
            pdftotext -layout "$input_file" "$output_file"
            if [ $? -eq 0 ]; then
                echo "BAŞARILI: $output_file"
                return 0
            fi

        # B) PDF -> HTML (Temiz Yöntem)
        elif [ "$target_format" == "html" ]; then
            echo "Bilgi: PDF web sayfasına çevriliyor..."
            OUTPUT_PREFIX="${output_dir}/${filename}"
            pdftohtml -s -noframes "$input_file" "$OUTPUT_PREFIX"
            
            if [ $? -eq 0 ]; then
                if [ -f "${OUTPUT_PREFIX}-s.html" ]; then
                    mv "${OUTPUT_PREFIX}-s.html" "$output_file"
                fi
                echo "BAŞARILI: Web sayfası oluşturuldu:\n$output_file"
                return 0
            else
                echo "HATA: Dönüştürme başarısız."
                return 1
            fi

        # C) PDF -> MD (Markdown)
        elif [ "$target_format" == "md" ]; then
            echo "Bilgi: PDF Markdown'a çevriliyor..."
            pdftohtml -stdout -noframes -i "$input_file" | pandoc -f html -t markdown -o "$output_file"
            
            if [ $? -eq 0 ]; then
                echo "BAŞARILI: Markdown dosyası oluşturuldu:\n$output_file"
                return 0
            else
                echo "HATA: Dönüştürme başarısız."
                return 1
            fi

        # D) PDF -> DOCX (Word) VEYA ODT (LibreOffice)  <-- BURASI GÜNCELLENDİ
        elif [ "$target_format" == "docx" ] || [ "$target_format" == "odt" ]; then
            echo "Bilgi: LibreOffice ile belgeye ($target_format) çevriliyor..."
            
            libreoffice --headless --infilter="writer_pdf_import" --convert-to "$target_format" "$input_file" --outdir "$output_dir"
            
            if [ $? -eq 0 ]; then
                echo "BAŞARILI: $output_file"
                return 0
            else
                echo "HATA: LibreOffice başarısız."
                return 1
            fi
            
        else
            echo "HATA: PDF'den bu formata dönüşüm desteklenmiyor."
            return 1
        fi

    # SENARYO 2: Diğer Formatlar (Pandoc)
    else
        echo "Bilgi: Pandoc dönüştürüyor..."
        pandoc "$input_file" -o "$output_file"
        
        if [ $? -eq 0 ]; then
            echo "BAŞARILI: Dosya kaydedildi:\n$output_file"
            return 0 
        else
            echo "HATA: Pandoc başarısız."
            return 1
        fi
    fi
}
