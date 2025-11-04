# nitro-attestation Setup Documentation

**Generated**: Mon Nov  3 19:22:02 UTC 2025
**User**: ubuntu
**Instance**: 

---

## System State

### OS Information
```
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
```

### Kernel
```
Linux ip-172-31-57-189 6.14.0-1015-aws #15~24.04.1-Ubuntu SMP Tue Sep 23 22:44:48 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
```

### Available Memory
```
               total        used        free      shared  buff/cache   available
Mem:            15Gi       2.5Gi       1.6Gi       2.7Mi        11Gi        12Gi
Swap:             0B          0B          0B
```

### Disk Usage
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        61G   16G   46G  26% /
```

---

## Installed Software

### docker
```
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
```

### cargo
```
cargo 1.91.0 (ea2d97820 2025-10-10)
```

### node
```
v20.19.5
```

### npm
```
10.8.2
```

### python3
```
Python 3.12.3
```

### git
```
git version 2.43.0
```


---

## Running Services

```
  UNIT                                           LOAD   ACTIVE SUB     DESCRIPTION
  acpid.service                                  loaded active running ACPI event daemon
  chrony.service                                 loaded active running chrony, an NTP client/server
  containerd.service                             loaded active running containerd container runtime
  cron.service                                   loaded active running Regular background program processing daemon
  dbus.service                                   loaded active running D-Bus System Message Bus
  docker.service                                 loaded active running Docker Application Container Engine
  fwupd.service                                  loaded active running Firmware update daemon
  getty@tty1.service                             loaded active running Getty on tty1
  irqbalance.service                             loaded active running irqbalance daemon
  ModemManager.service                           loaded active running Modem Manager
  multipathd.service                             loaded active running Device-Mapper Multipath Device Controller
  networkd-dispatcher.service                    loaded active running Dispatcher daemon for systemd-networkd
  orbs-tee-enclave.service                       loaded active running ORBS TEE Price Oracle Enclave
  orbs-tee-host.service                          loaded active running ORBS TEE Host API Server
  polkit.service                                 loaded active running Authorization Manager
  rsyslog.service                                loaded active running System Logging Service
  serial-getty@ttyS0.service                     loaded active running Serial Getty on ttyS0
  snap.amazon-ssm-agent.amazon-ssm-agent.service loaded active running Service for snap application amazon-ssm-agent.amazon-ssm-agent
  snapd.service                                  loaded active running Snap Daemon
```

---

## Network Configuration

### Listening Ports
```
Netid State  Recv-Q Send-Q      Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0              127.0.0.54:53         0.0.0.0:*          
udp   UNCONN 0      0           127.0.0.53%lo:53         0.0.0.0:*          
udp   UNCONN 0      0      172.31.57.189%ens5:68         0.0.0.0:*          
udp   UNCONN 0      0               127.0.0.1:323        0.0.0.0:*          
udp   UNCONN 0      0                   [::1]:323           [::]:*          
tcp   LISTEN 0      4096            127.0.0.1:37271      0.0.0.0:*          
tcp   LISTEN 0      4096           127.0.0.54:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.53%lo:53         0.0.0.0:*          
tcp   LISTEN 0      4096              0.0.0.0:22         0.0.0.0:*          
tcp   LISTEN 0      511               0.0.0.0:8443       0.0.0.0:*          
tcp   LISTEN 0      4096                 [::]:22            [::]:*          
```

### Firewall Status
```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy DROP)
target     prot opt source               destination         
DOCKER-USER  0    --  0.0.0.0/0            0.0.0.0/0           
DOCKER-FORWARD  0    --  0.0.0.0/0            0.0.0.0/0           

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain DOCKER (1 references)
target     prot opt source               destination         
DROP       0    --  0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-BRIDGE (1 references)
target     prot opt source               destination         
DOCKER     0    --  0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-CT (1 references)
```

---

## Recent File Changes (Last Hour)

### Modified Files
```
/home/ubuntu/price-oracle-v2.eif
/home/ubuntu/.nitro_cli/bootstrap-initrd.img-initrd.img
/home/ubuntu/.nitro_cli/customer-initrd.img-initrd.img
/home/ubuntu/attestation_document.bin
/home/ubuntu/price-oracle.eif
/home/ubuntu/nitro-attestation-20251103-192202.md
/home/ubuntu/verify-enclave.sh
/home/ubuntu/orbs-tee-enclave-nitro/src/app.rs
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/Cargo.lock
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/price-oracle-enclave.d
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/root-output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/invoked.timestamp
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/stderr
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/root-output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/invoked.timestamp
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/stderr
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/root-output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/invoked.timestamp
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/stderr
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/root-output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/invoked.timestamp
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/stderr
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6/root-output
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6/invoked.timestamp
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6/stderr
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6/output
```

### New Directories
```
/home/ubuntu
/home/ubuntu/.nitro_cli
/home/ubuntu/orbs-tee-enclave-nitro
/home/ubuntu/orbs-tee-enclave-nitro/src
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/typenum-b974ecb0f18612fb
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/proc-macro2-56fb6f1491e966f1
```

---

## Key Files

### /home/ubuntu/orbs-tee-host/config.json
- **Size**: 587
- **Modified**: 2025-11-03 17:46:43.054149280 +0000

### /etc/nitro_enclaves/allocator.yaml
- **Size**: 154
- **Modified**: 2025-11-03 18:58:28.374154953 +0000

### /home/ubuntu/price-oracle-v2.eif
- **Size**: 154M
- **Modified**: 2025-11-03 19:17:28.685318410 +0000

### /home/ubuntu/price-oracle.eif
- **Size**: 154M
- **Modified**: 2025-11-03 18:57:23.499692199 +0000

### /home/ubuntu/attestation_document.bin
- **Size**: 4.5K
- **Modified**: 2025-11-03 19:19:46.861153040 +0000


---

## Memory Configuration

### Hugepages
```
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:     640
HugePages_Free:      128
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:         1310720 kB
```

---

## Recent Logs

### System Logs (Last 20 lines)
```
Nov 03 19:17:32 ip-172-31-57-189 amazon-ssm-agent.amazon-ssm-agent[576]: 2025-11-03 19:17:32.3390 ERROR EC2RoleProvider Failed to connect to Systems Manager with SSM role credentials. error calling RequestManagedInstanceRoleToken: AccessDeniedException: Systems Manager's instance management role is not configured for account: 506367651493
Nov 03 19:17:32 ip-172-31-57-189 amazon-ssm-agent.amazon-ssm-agent[576]:         status code: 400, request id: 1701925d-683f-4015-a3af-af69657e069a
Nov 03 19:17:32 ip-172-31-57-189 amazon-ssm-agent.amazon-ssm-agent[576]: 2025-11-03 19:17:32.3390 ERROR [CredentialRefresher] Retrieve credentials produced error: no valid credentials could be retrieved for ec2 identity. Default Host Management Err: error calling RequestManagedInstanceRoleToken: AccessDeniedException: Systems Manager's instance management role is not configured for account: 506367651493
Nov 03 19:17:32 ip-172-31-57-189 amazon-ssm-agent.amazon-ssm-agent[576]:         status code: 400, request id: 1701925d-683f-4015-a3af-af69657e069a
Nov 03 19:17:32 ip-172-31-57-189 fwupd[47473]: 19:17:32.557 FuPluginUefiCapsule  SMBIOS BIOS Characteristics Extension Byte 2 is invalid -- UEFI Specification is unsupported, but /sys/firmware/efi exists: System does not support UEFI mode
Nov 03 19:17:32 ip-172-31-57-189 amazon-ssm-agent.amazon-ssm-agent[576]: 2025-11-03 19:17:32.3391 INFO [CredentialRefresher] Sleeping for 25m32s before retrying retrieve credentials
Nov 03 19:17:32 ip-172-31-57-189 fwupd[47473]: 19:17:32.742 FuMain               fwupd 1.9.31 ready for requests (locale C.UTF-8)
Nov 03 19:17:32 ip-172-31-57-189 dbus-daemon[564]: [system] Successfully activated service 'org.freedesktop.fwupd'
Nov 03 19:17:32 ip-172-31-57-189 systemd[1]: Started fwupd.service - Firmware update daemon.
Nov 03 19:17:32 ip-172-31-57-189 fwupd[47473]: 19:17:32.747 FuPluginLinuxSleep   could not open /sys/power/mem_sleep: Error opening file /sys/power/mem_sleep: No such file or directory
Nov 03 19:17:32 ip-172-31-57-189 systemd[1]: fwupd-refresh.service: Deactivated successfully.
Nov 03 19:17:32 ip-172-31-57-189 systemd[1]: Finished fwupd-refresh.service - Refresh fwupd metadata and update motd.
Nov 03 19:20:16 ip-172-31-57-189 systemd[1]: Starting sysstat-collect.service - system activity accounting tool...
Nov 03 19:20:16 ip-172-31-57-189 systemd[1]: sysstat-collect.service: Deactivated successfully.
Nov 03 19:20:16 ip-172-31-57-189 systemd[1]: Finished sysstat-collect.service - system activity accounting tool.
Nov 03 19:22:02 ip-172-31-57-189 sudo[47757]:   ubuntu : PWD=/home/ubuntu/orbs-tee-enclave-nitro ; USER=root ; COMMAND=/usr/sbin/iptables -L -n
Nov 03 19:22:02 ip-172-31-57-189 sudo[47757]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
Nov 03 19:22:02 ip-172-31-57-189 sudo[47757]: pam_unix(sudo:session): session closed for user root
Nov 03 19:22:03 ip-172-31-57-189 sudo[47792]:   ubuntu : PWD=/home/ubuntu/orbs-tee-enclave-nitro ; USER=root ; COMMAND=/usr/bin/journalctl -n 20
Nov 03 19:22:03 ip-172-31-57-189 sudo[47792]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
```

---

## Environment Variables (Filtered)

```
HOME=/home/ubuntu
PATH=/home/ubuntu/.local/bin:/home/ubuntu/.cargo/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
USER=ubuntu
```

---

## Quick Commands Reference

```bash
# Check enclave status
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli describe-enclaves

# View logs
sudo journalctl -u nitro-enclaves-allocator -f

# Test enclave
python3 /home/ubuntu/test-enclave-full.py

# Verify setup
/home/ubuntu/verify-enclave.sh
```

---

**Documentation generated automatically by auto-document-setup.sh**
**Saved to**: /home/ubuntu/nitro-attestation-20251103-192202.md
