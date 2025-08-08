#!/bin/bash

# Fungsi untuk memverifikasi login root
function verify_root_login() {
    echo "======================================"
    echo "      Login sebagai root diperlukan    "
    echo "======================================"
    read -sp "Masukkan password root: " root_password
    echo

    # Verifikasi apakah password root valid
    echo "$root_password" | sudo -kS echo "" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Password salah. Silakan coba lagi."
        sleep 2
        clear
        verify_root_login
    else
        echo "Login berhasil!"
        sleep 2
    fi
}

# Memanggil fungsi login sebelum melanjutkan
verify_root_login

# Menu utama
while true; do
    clear
    echo "======================================"
    echo "         Elasticsearch & Kibana       "
    echo "======================================"
    echo "1. Update & Upgrade Sistem"
    echo "2. Install Elasticsearch"
    echo "3. Install Kibana & Logstash"
    echo "4. Generate Token & Kode Verifikasi Kibana"
    echo "5. Reset Password Elasticsearch"
    echo "6. Restart Service"
    echo "0. Keluar"
    echo "======================================"
    read -p "Pilih opsi [0-6]: " opsi

    case $opsi in
        1)
            echo "Melakukan update & upgrade sistem..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install apt-transport-https curl gnupg -y
            sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
            sudo echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
            sudo apt update
            echo "Update & upgrade selesai."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        2)
            echo "Menginstal Elasticsearch..."
            sudo apt install elasticsearch -y
	          sudo echo "indices.query.bool.max_clause_count: 2000" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
	          sudo echo "http.max_content_length: 400mb" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
	          sudo echo "network.host: $(hostname -I | awk '{print $1}')" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
     	      sudo echo "-Xms4g" | sudo tee -a /etc/elasticsearch/jvm.options
	          sudo echo "-Xmx4g" | sudo tee -a /etc/elasticsearch/jvm.options
            sudo systemctl daemon-reload
            sudo systemctl enable elasticsearch.service
            sudo systemctl start elasticsearch.service
            echo "Elasticsearch berhasil diinstal."
            echo "Elasticsearch dapat diakses melalui https://$(hostname -I | awk '{print $1}'):9200"
            echo "Silahkan Melakukan Reset Password Elasticsearch terlebih dahulu!"
            echo "Pada opsi [5. Reset Password Elasticsearch]"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        3)
            echo "Menginstal Kibana & Logstash..."
            sudo apt install kibana logstash -y
            sudo /usr/share/kibana/bin/kibana-encryption-keys generate >> encrypt.txt
      	    sudo grep "xpack.encryptedSavedObjects.encryptionKey:" encrypt.txt | sudo tee -a /etc/kibana/kibana.yml
      	    sudo grep "xpack.reporting.encryptionKey:" encrypt.txt | sudo tee -a /etc/kibana/kibana.yml
      	    sudo grep "xpack.security.encryptionKey:" encrypt.txt | sudo tee -a /etc/kibana/kibana.yml
      	    sudo echo "xpack.integration_assistant.enabled: false" | sudo tee -a /etc/kibana/kibana.yml
      	    sudo echo "server.host: $(hostname -I | awk '{print $1}')" | sudo tee -a /etc/kibana/kibana.yml
            sudo systemctl daemon-reload
            sudo systemctl enable kibana.service
            sudo systemctl start kibana.service
            rm encrypt.txt
            echo "Kibana berhasil diinstal."
            echo "Kibana dapat diakses melalui http://$(hostname -I | awk '{print $1}'):5601"
            echo "Selanjutnya Masukkan Token & Kode Verifikasi Kibana terlebih dahulu!"
            echo "Pada opsi [4. Generate Token & Kode Verifikasi Kibana]"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        4)  
            echo "Silahkan Masukkan Token Kibana ini Pada Web: "
            echo ""
      	    sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana 
      	    echo ""
      	    echo "======================================"
      	    echo ""
      	    sleep 2
      	    echo "Silahkan Masukkan Kode Verifikasi Kibana ini Pada Web: "
      	    echo ""
            read -p "Tekan Enter untuk mendapatkan Verification Code."
      	    sudo /usr/share/kibana/bin/kibana-verification-code
      	    echo ""
      	    sleep 1
      	    read -p "Tekan Enter untuk kembali ke menu."
            ;;
        5)
            echo "Reset password Elasticsearch..."
            sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        6)
            echo "Restart Semua Service..."
            sleep 1
            echo "Restart Elasticsearch..."
            sudo systemctl restart elasticsearch
            sleep 1
            echo "Elasticsearch selesai Restart!"
            sleep 1
            echo "Restart Kibana"
            sudo systemctl restart kibana
            sleep 1
            echo "Kibana selesai Restart!"
            sleep 1
            echo "Restart Logstash"
            sudo systemctl restart Logstash
            sleep 1
            echo "Logstash selesai Restart!"

	    read -p "Tekan Enter untuk kembali ke menu."
            ;;
        0)
            echo "Keluar dari menu. Sampai jumpa!"
            sleep 1
            clear
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid. Coba lagi."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
    esac
done
