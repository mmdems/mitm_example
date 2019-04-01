# mitm_example

Project was implemented to understand processes of packet sniffing at low-level of ISO/OSI model.
System contains 2 SC FIFOs. Of course real systems DC FIFOs. But it's just prototype

With help of this system you can:
* listen the channel
* add some user packets with determined data insdide
* check CRC32 of packet going through the channel
* kill any packet
* fix data of any packet

# Interfaces
System has simple converters: from GMII into RGMII and vice versa

# FIFOs
fifo_main.vhd is main FIFO. It's used for storing data while we sniffing packets.
fifo_inject.vhd is used for packet injection. Injected packets are being injected 'between' main packets

# CRC32
This block is used for checking CRC32. It has crc_valid output which detects
correct CRC
