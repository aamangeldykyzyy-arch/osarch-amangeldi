markdown
| Part | 	What goes in it 
|---|---|---|
|Allocation |I gave the guest 2 vCPU for bor both guests, 2 GB of RAM for ubuntu and 4 GB of RAN=M for windows, I gave it a 20 GB dynamically allocated disk for ubuntu and 20 GB for windouws, I used NAT mode for both VMs  
| Arithmetic | memory: 16-10-2-4= 0 GB, storage:512-157-20-25= 310GB 
| Justification |The VMs must see each other and have internet. NAT does both: both VMs are on the same virtual network (192.168.245.x), and they get internet through my laptop. I did not use bridged, because the campus network blocks devices that are not registered. I did not use host-only, because it has no internet. | Result |
note: this computer cannot run both guests as asked, because the number of RAM left is not efficient at all. The VM wont be able to even be opened.
