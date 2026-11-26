# Laporan Resmi Praktikum Modul 5 Jaringan Komputer 2026
## *Operation Geofront* — Kelompok K-43

**Anggota Kelompok:**
- Kelompok K-43 (Group B — GNS3 Host: `10.4.89.247`)
- Blok Subnet: `10.85.0.0/16`

---

## Daftar Isi
1. [Babak 1 — Soal 1: Pembagian Alamat VLSM & Tree IP](#soal-1--pembagian-alamat-vlsm--tree-ip)
2. [Babak 1 — Soal 2: IP Addressing 17 Router & Ping Ujung Link](#soal-2--ip-addressing-17-router--ping-ujung-link)
3. [Babak 1 — Soal 3: Routing Statis & CIDR Summarization](#soal-3--routing-statis--cidr-summarization)
4. [Babak 1 — Soal 4: Akses Internet & NAT Masquerade Gendo](#soal-4--akses-internet--nat-masquerade-gendo)
5. [Babak 1 — Soal 5: Firewall Hardening Gendo (Default Policy DROP)](#soal-5--firewall-hardening-gendo-default-policy-drop)
6. [Babak 1 — Soal 6: IP Statis Permanen Non-Router & Uji Gateway Unit-01](#soal-6--ip-statis-permanen-non-router--uji-gateway-unit-01)
7. [Babak 1 — Soal 7: Membangunkan Layanan MAGI (Netcat Listener)](#soal-7--membangunkan-layanan-magi-netcat-listener)
8. [Babak 1 — Soal 8: Mengenali Kondisi Normal & Uji Layanan](#soal-8--mengenali-kondisi-normal--uji-layanan)

---

## Soal 1 — Pembagian Alamat VLSM & Tree IP
- Pembagian subnet dilakukan berdasarkan kebutuhan host terbesar (termasuk +1 gateway) dengan aturan tie-break: ukuran sama didahulukan segmen LAN dibanding link router-ke-router, kemudian urutan nomor tabel.
- File rincian subnetting tersedia pada spreadsheet: [`subneting.xlsx`](subneting.xlsx).
- Total segmen: 17 LAN dan 16 Link Point-to-Point (/30).

---

## Soal 2 — IP Addressing 17 Router & Ping Ujung Link
Setiap router dikonfigurasi dengan IP statis dan `net.ipv4.ip_forward=1`. Router Gendo memperoleh alamat dinamis dari NAT1 via interface WAN `eth7`.

### A. Tampilan `ip -br a` pada 17 Router
| No | Router | Screenshot |
|:--:|:-------|:-----------|
| 1 | **Gendow** | ![Gendow](Images/1.png) |
| 2 | **Fuyutsuki** | ![Fuyutsuki](Images/2.png) |
| 3 | **Maya** | ![Maya](Images/3.png) |
| 4 | **Toji** | ![Toji](Images/4.png) |
| 5 | **Shigeru** | ![Shigeru](Images/5.png) |
| 6 | **Makoto** | ![Makoto](Images/6.png) |
| 7 | **Misato** | ![Misato](Images/Pasted%20image.png) |
| 8 | **Kaji** | ![Kaji](Images/Pasted%20image%20(2).png) |
| 9 | **Asuka** | ![Asuka](Images/Pasted%20image%20(3).png) |
| 10 | **Ritsuko** | ![Ritsuko](Images/Pasted%20image%20(4).png) |
| 11 | **Kensuke** | ![Kensuke](Images/Pasted%20image%20(5).png) |
| 12 | **Hikari** | ![Hikari](Images/Pasted%20image%20(6).png) |
| 13 | **Kowaru** | ![Kowaru](Images/Pasted%20image%20(7).png) |
| 14 | **Yui** | ![Yui](Images/Pasted%20image%20(8).png) |
| 15 | **Mari** | ![Mari](Images/Pasted%20image%20(9).png) |
| 16 | **Rei** | ![Rei](Images/Pasted%20image%20(10).png) |
| 17 | **Shinji** | ![Shinji](Images/Pasted%20image%20(11).png) |

### B. Ping Dua Ujung Tiap Link Router-ke-Router
- **Gendow ke 7 Router Cabang**:  
  ![Ping Gendow](Images/Pasted%20image%20(12).png)
- **Cabang Fuyutsuki & Shigeru**:  
  ![Ping Fuyutsuki & Shigeru](Images/Pasted%20image%20(13).png)
- **Cabang Asuka & Hikari**:  
  ![Ping Asuka & Hikari](Images/Pasted%20image%20(14).png)
- **Cabang Yui**:  
  ![Ping Yui](Images/Pasted%20image%20(15).png)

---

## Soal 3 — Routing Statis & CIDR Summarization
Routing statis diatur dengan prinsip hierarki efisien:
- Router cabang mengarahkan default route ke router induk di atasnya.
- Router Gendo mengarahkan rute spesifik ke masing-masing cabang, dengan ringkasan CIDR pada cabang Shigeru (Switch-Monolith `10.85.4.80/29` + Switch-Radar `10.85.4.88/29` diringkas tepat menjadi `10.85.4.80/28`).
- Bukti ping dari **Armisael** (`10.85.4.83`) ke:
  - **Lilith** (`10.85.4.74`)
  - **Sachiel** (`10.85.3.130`)
  - **Comm-Net** (`10.85.2.2`)  
  ![Ping Armisael Soal 3](Images/Pasted%20image%20(16).png)

---

## Soal 4 — Akses Internet & NAT Masquerade Gendo
- Router Gendo menerapkan NAT Masquerade pada dynamic WAN interface `eth7`:
  ```bash
  iptables -t nat -A POSTROUTING -s 10.85.0.0/16 -o eth7 -j MASQUERADE
  ```
- DNS nameserver dikonfigurasi pada `/etc/resolv.conf`.
- Bukti ping `8.8.8.8` dan domain `deb.debian.org` dari node internal:  
  ![Ping Internet & Domain](Images/Pasted%20image%20(17).png)
- Bukti counter rule NAT bertambah di Gendow (`iptables -t nat -nvL POSTROUTING`):  
  ![Counter NAT](Images/Pasted%20image%20(18).png)

---

## Soal 5 — Firewall Hardening Gendo (Default Policy DROP)
Router Gendo menerapkan firewall stateful:
- Policy default rantai `INPUT` dan `FORWARD` adalah `DROP`.
- Loopback `lo` dan DHCP WAN `eth7` diizinkan.
- Conntrack `ESTABLISHED,RELATED` diizinkan melintasi firewall.
- Internal `10.85.0.0/16` diizinkan keluar ke internet via `eth7`.
- Komunikasi antar-LAN internal diizinkan (`! -o eth7`).
- Akses internal ke router Gendo diizinkan untuk pemeliharaan.

### Bukti Aturan & Uji Firewall:
- Daftar aturan firewall di router Gendo (`iptables -S`):  
  ![Firewall Gendow](Images/Pasted%20image%20(19).png)
- Uji ping ke `8.8.8.8` dari Armisael membuktikan akses internet tetap berjalan di bawah policy DROP:  
  ![Uji Internet Firewall](Images/Pasted%20image%20(20).png)

---

## Soal 6 — IP Statis Permanen Non-Router & Uji Gateway Unit-01
- Seluruh 25 node client non-router diberi IP statis dan default gateway sesuai aturan glosarium.
- Konfigurasi dipatenkan dengan script `/root/<nama>.sh`, auto-hook `/root/.bashrc`, dan `/etc/network/interfaces`.
- Bukti `ip -br a` dan ping ke gateway Misato (`10.85.4.65`) pada **Unit-01**:  
  ![Unit-01 Gateway Ping](Images/Pasted%20image%20(21).png)

---

## Soal 7 — Membangunkan Layanan MAGI (Netcat Listener)
Layanan listener netcat diaktifkan pada:
- **Magi-Casper**: Port 5000
- **Magi-Balthasar**: Port 5000 & 5001
- **Magi-Melchior**: Port 5000

### Bukti Pengiriman & Penerimaan Pesan:
- Lilith mengirim pesan ke keempat listener:  
  ![Lilith Kirim MAGI](Images/Pasted%20image%20(23).png)
- Pesan diterima di masing-masing node MAGI:  
  ![MAGI Menerima Pesan](Images/Pasted%20image%20(22).png)

---

## Soal 8 — Mengenali Kondisi Normal & Uji Layanan
Layanan normal diuji dari node Lilith:
- **Pen-Pen** (Port 80): Menjawab `Welcome to Pen-pen`
- **Tokyo3-Core** (Port 80): Menjawab `Welcome to Tokyo3-Core`
- **Tokyo3-Core** (Port 8080): Menjawab `syifa imutz`
- **Port 22 (Tidak Dilayani)**: Langsung gagal (`Connection refused`), tidak menggantung.

### Bukti Uji Layanan:
![Uji Layanan Soal 8](Images/Pasted%20image%20(24).png)
