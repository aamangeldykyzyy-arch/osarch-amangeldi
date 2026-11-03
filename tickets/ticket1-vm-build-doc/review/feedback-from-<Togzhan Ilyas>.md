# Feedback on Amangeldi's BUILD.md

*Reviewer:* Togzhan

*Commit reviewed:* https://github.com/aamangeldykyzyy-arch/osarch-amangeldi/tree/c8e18c944423ee87fde701c9fd05768ad1960f71/tickets/ticket1-vm-build-doc

*Hypervisor I used:* VMware Workstation 26h1

## First step where I got stuck

*Step number:* B8

*What the step says:*
Start the Windows VM using "Power On to Firmware", select "EFI VMware Virtual SATA CDROM Drive" and immediately press Space several times.

*What I did:*
I followed the instructions, opened the VM, selected the EFI drive and tried to continue.

*What happened / what I had to guess:*
I was not completely sure when exactly I needed to start pressing Space. The timing was a little confusing, so I had to try again. It would be helpful to explain this moment a bit more clearly.

## Other places I hesitated

- *Step A12:* When the red "Confirm destructive action" message appeared, I wanted to make sure that it would only affect the virtual disk and not my actual computer. The explanation helped, but I still paused before continuing.
- *Step B5:* I was not completely sure what the TPM encryption option meant and whether I needed to change anything. The explanation helped me understand what to select.

## Settings I would not have chosen without the document

- NAT network instead of Bridged or Host-only.
- 2048 MB RAM for Ubuntu and 4096 MB for Windows.
- 2 processors for each virtual machine.
- 25 GB disk space for Ubuntu and 64 GB for Windows.
- The TPM encryption settings required for Windows 11.

## One thing that worked well

The screenshots helped me compare the instructions with what I saw on my screen. I also liked that the document included exact values for the settings, so I did not have to choose them myself.
Some steps could use a little more explanation, but overall the guide was understandable and easy to follow.
